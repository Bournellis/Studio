#!/usr/bin/env python3
import sys
from estudio_repository_checks import main

raise SystemExit(main(["health", *sys.argv[1:]]))
