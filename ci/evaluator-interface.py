#!/usr/bin/env python3
"""Exercise the caller's aggregate against its ci input's package identities."""

import json
import os
from pathlib import Path
import subprocess
import sys


def run(executable, args, env):
    result = subprocess.run([str(executable), *args], env=env, text=True, capture_output=True)
    if result.returncode:
        raise RuntimeError(f"{executable} {' '.join(args)}: exit {result.returncode}: {result.stderr}")
    return result.stdout


def exercise(root, identities, closure):
    if set(identities) != {"nix", "determinate", "lix"}:
        raise RuntimeError("expected package identities do not name all three families")
    retained = set(closure.read_text().splitlines())
    for family, identity in identities.items():
        executable = root / family / "bin/nix"
        actual = executable.resolve(strict=True)
        expected = Path(identity["executable"]).resolve(strict=True)
        if actual != expected:
            raise AssertionError(f"{family}: path mismatch: {actual} != {expected}")
        if str(expected.parent.parent) not in retained:
            raise AssertionError(f"{family}: executable package absent from aggregate closure")
        configuration = (root / family / "nix.conf").read_text()
        declared = {}
        for line in configuration.splitlines():
            line = line.partition("#")[0].strip()
            if line:
                key, separator, value = line.partition("=")
                if not separator:
                    raise RuntimeError(f"{family}: invalid configuration line: {line}")
                declared[key.strip()] = value.strip()
        if not {"show-trace", "nix-path"} <= declared.keys():
            raise RuntimeError(f"{family}: configuration lacks workflow settings")
        env = dict(os.environ, NIX_CONFIG=configuration)
        env.pop("NIX_PATH", None)
        banner = run(executable, ["--version"], env)
        if identity["version"] not in banner:
            raise AssertionError(f"{family}: version mismatch: {banner.strip()}")
        settings = json.loads(run(executable, ["config", "show", "--json"], env))
        for key, value in declared.items():
            effective = settings[key]["value"]
            if isinstance(effective, bool):
                agrees = value == str(effective).lower()
            elif isinstance(effective, list):
                agrees = set(value.split()) <= set(effective) if key == "experimental-features" else value.split() == effective
            else:
                agrees = str(effective) == value
            if not agrees:
                raise AssertionError(f"{family}: setting {key}: {effective!r} != {value!r}")
        if family == "determinate" and settings["lazy-trees"]["value"] is not True:
            raise AssertionError("determinate: lazy-trees is not enabled")
        value = json.loads(run(executable, ["eval", "--store", "dummy://", "--json", "--expr", "6 * 7"], env))
        if value != 42:
            raise AssertionError(f"{family}: evaluated value {value!r} != 42")
        print(f"{family}: path={actual}; version={banner.splitlines()[0]}; value={value}; settings={json.dumps(declared, sort_keys=True)}")


if __name__ == "__main__":
    try:
        root, manifest, closure = map(Path, sys.argv[1:])
        exercise(root, json.loads(manifest.read_text()), closure)
    except (OSError, ValueError, KeyError, RuntimeError, AssertionError) as error:
        print(f"evaluator-interface: FAIL: {error}", file=sys.stderr)
        sys.exit(1)
