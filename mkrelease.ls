#!/usr/bin/env lsc

{exec, run} = require 'execSync'

fsx = require 'fs-extended'
copy = fsx.copySync
mkdir = fsx.createDirSync
remove = fsx.deleteSync
write = fsx.createFileSync
readJSON = fsx.readJSONSync
writeJSON = fsx.writeJSONSync
exists = fsx.existsSync
mv = fsx.moveSync

version = '1.14'
jsfiles = <[ background.js feedlearn.js feedlearninstalled.js jquery-1.11.1.min.js jquery.isinview.js ]>

base_permissions = [
  "cookies"
  "http://facebook.com/*"
  "https://facebook.com/*"
  "http://www.facebook.com/*"
  "https://www.facebook.com/*"
]

base_content_scripts = [ {
  "all_frames": true
  "js": [ "jquery-1.11.1.min.js", "jquery.isinview.js", "baseurl.js", "feedlearn.js" ]
  "matches": [ "http://facebook.com/*", "https://facebook.com/*", "http://www.facebook.com/*", "https://www.facebook.com/*" ]
  "run_at": "document_end"
} ]

buildinfo_list = [
  {
    name: 'Feed Learn Local'
    short_name: 'feedlearnlocal'
    outdir: '.'
    baseurl: 'https://localhost:5001'
    permissions: base_permissions ++ [
      "http://localhost:5000/*"
      "https://localhost:5001/*"
    ]
    content_scripts: base_content_scripts ++ [ {
      "all_frames": true,
      "js": [ "jquery-1.11.1.min.js", "feedlearninstalled.js" ]
      "matches": [ "http://localhost:5000/study1", "https://localhost:5001/study1" ]
      "run_at": "document_end"
    } ]
  }
  {
    name: 'Feed Learn'
    short_name: 'feedlearn'
    baseurl: 'https://feedlearn.herokuapp.com'
    permissions: base_permissions ++ [
      "http://feedlearn.herokuapp.com/*"
      "https://feedlearn.herokuapp.com/*"
    ]
    content_scripts: base_content_scripts ++ [ {
      "all_frames": true,
      "js": [ "jquery-1.11.1.min.js", "feedlearninstalled.js" ]
      "matches": [ "http://feedlearn.herokuapp.com/study1", "https://feedlearn.herokuapp.com/study1" ]
      "run_at": "document_end"
    } ]
  }
  {
    name: 'Feed Learn 2'
    short_name: 'feedlearn2'
    baseurl: 'https://feedlearn2.herokuapp.com'
    permissions: base_permissions ++ [
      "http://feedlearn2.herokuapp.com/*"
      "https://feedlearn2.herokuapp.com/*"
    ]
    content_scripts: base_content_scripts ++ [ {
      "all_frames": true,
      "js": [ "jquery-1.11.1.min.js", "feedlearninstalled.js" ]
      "matches": [ "http://feedlearn2.herokuapp.com/study1", "https://feedlearn2.herokuapp.com/study1" ]
      "run_at": "document_end"
    } ]
  }
]

manifest_template = readJSON 'manifest.json'
origdir = process.cwd()

for buildinfo in buildinfo_list
  manifest = {[k,v] for k,v of manifest_template}
  {short_name, baseurl, outdir} = buildinfo
  manifest.version = version
  for k,v of buildinfo
    if <[ baseurl outdir ]>.indexOf(k) != -1
      continue
    manifest[k] = v
  if not outdir?
    outdir = 'build_' + short_name
  outfile = short_name + '-' + version + '.zip'
  if exists outfile
    remove outfile
  if outdir != '.'
    if exists outdir
      remove outdir
    mkdir outdir
    for file in jsfiles
      copy file, outdir + '/' + file
  process.chdir outdir
  writeJSON 'manifest.json', manifest, '  '
  write 'baseurl.js', "baseurl = '#{baseurl}';\n"
  run "zip #{outfile} *js manifest.json"
  mv outfile, origdir + '/' + outfile
  process.chdir origdir
