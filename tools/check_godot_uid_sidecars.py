#!/usr/bin/env python3
import sys
from estudio_repository_checks import main

raise SystemExit(main(["uids", *sys.argv[1:]]))
