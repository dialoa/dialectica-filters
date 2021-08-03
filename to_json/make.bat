@echo off

if /I "%1"=="all" goto all
if /I "%1"=="" goto all
goto error

:all
	pandoc -t json sample.md -o expected.json
	pandoc -L to_json.lua sample.md > result.json
	fc /A /U expected.json result.json