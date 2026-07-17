#!/usr/bin/env python3
import sys
from estudio_governance import main

raise SystemExit(main(["text", *sys.argv[1:]]))
