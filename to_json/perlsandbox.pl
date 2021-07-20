$foo = '{"pandoc-api-version":[1,22],"meta":{},"blocks":[{"t":"Para","c":[{"t":"Str","c":"\Minimal"},{"t":"Space"},{"t":"Str","c":"document."}]}]}
';
$foo =~ s/\\/\\\\/g;
$foo =~ s/\"/\\"/g;
$foo =~ s/^/{"pandoc-api-version":[1,22],"meta":{},"blocks":[{"t":"RawBlock","c":["json","/;
$foo =~ s/$/"]}]}/;

print($foo)