#!/usr/bin/env python3
import sys
from estudio_governance import main

raise SystemExit(main(["docs", *sys.argv[1:]]))
