{pybin} -c 'from ctypesgen import main as ctypeswrap; ctypeswrap.main()' -l{plugin} -I. -I{inc_dir} {srcdir}/{plugin}.h -o {outdir}/{plugin}_generated.py

# WAR for 'const char**' being generated as POINTER(POINTER(c_char)) instead of POINTER(c_char_p)
sed -i 's/POINTER(c_char)/c_char_p/g' {outdir}/{plugin}_generated.py

# WAR for a buggy WAR in ctypesgen that breaks type checking and auto-byref functionality
sed -i 's/def POINTER/def POINTER_not_used/' {outdir}/{plugin}_generated.py

# WAR for a buggy WAR in ctypesgen that breaks string buffer arguments (e.g., as in address.py)
sed -i 's/class String/String = c_char_p\\nclass String_not_used/' {outdir}/{plugin}_generated.py
sed -i 's/String.from_param/String_not_used.from_param/g' {outdir}/{plugin}_generated.py
sed -i 's/def ReturnString/ReturnString = c_char_p\\ndef ReturnString_not_used/' {outdir}/{plugin}_generated.py
sed -i '/errcheck = ReturnString/s/^/#/' {outdir}/{plugin}_generated.py

# Move generate file to output directory
touch {outdir}/__init__.py