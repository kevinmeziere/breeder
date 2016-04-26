#!/opt/local/bin/python

import urllib2
import xml.etree.ElementTree as ET
from distutils.version import LooseVersion, StrictVersion

site= "http://release.project-fifo.net?prefix=pkg%2Frel%2Ffifo"
hdr = {'User-Agent': 'Current Version Tool - Fetch'}

req = urllib2.Request(site, headers=hdr)

response = urllib2.urlopen(req)
releases = response.read()

root = ET.fromstring(releases)

current = {}

for node in root.findall('{http://s3.amazonaws.com/doc/2006-03-01/}Contents'):
        key = node.find('{http://s3.amazonaws.com/doc/2006-03-01/}Key')
        parts = key.text.split('-')
        if len(parts) > 1:
                tail = parts.pop()
                name = "-".join(parts)
                version_parts = tail.split('.')
                if len(version_parts) > 2:
                        version_parts.pop()
                        version = ".".join(version_parts)
                        if (not name in current) or (LooseVersion(current[name]) < LooseVersion(version)):
                                current[name] = version

for k,v in current.items():
    print k + '-' + v