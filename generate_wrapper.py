#!/usr/bin/env python

import os
import sys
import argparse

inc_dir = os.getcwd()

def read_template(filename, subs={}):
    """ Read a template file, replacing with subs

    Template files follow f-string {name} convention

    Returns:
        d (str): template output
    """
    with open(f'templates/{filename}', 'r') as fh:
        d = fh.read()
    for substr, subval in subs.items():
        d = d.replace('{%s}' % substr, subval)
    return d

def find_and_replace(filepath, tpl_find, tpl_replace, subs={}):
    """ Do a find and replace in a file using a template 

    The filepath is usually an auto-generated file that needs
    some tweaking before use.
    
    Args:
        filepath (str): Path to file to replace strings in
        tpl_find (str): Name of find template in templates/
        tpl_replace (str): Name of replace template in templates/

    Returns:
        Nothing -- changes are written directly to file
    """
    to_find = read_template(tpl_find)
    to_del  = read_template(tpl_replace)

    with open(filepath, 'r') as fh:
        data = fh.read()
        data = data.replace(to_find, to_del)

    with open(filepath, 'w') as fh:
        fh.write(data)


def generate_and_patch(plugin, inc_dir=None, pybin='python', srcdir='./', outdir='./'):
    cmd = read_template('ctypes_command.tpl', 
                        subs={'plugin': plugin, 'inc_dir': inc_dir, 'pybin': pybin, 
                              'srcdir': srcdir, 'outdir': outdir})

    # Run each line of the ctypes command
    import os
    ret = 0
    for line in cmd.split('\n'):
        ret = os.system(line)
        if ret != 0:
            print(f"ERROR: Command failed:\n\t{line}")
            break
    plugin
    if ret == 0:
        # Run find and replace to delete that pesky structbf 
        find_and_replace(f"{outdir}/{plugin}_generated.py", 
                        tpl_find='war_structbf.tpl', tpl_replace='war_structbf.tpl')
        
if __name__ == "__main__":
    p = argparse.ArgumentParser(description="Generate python wrapper using ctypesgen for bifrost")
    p.add_argument('plugin_name', help='Name of plugin to generate (without .cu or .h)')
    p.add_argument('-o', '--outdir', help='Name of output directory', default='./')
    p.add_argument('-p', '--pybin', help='Python version to use in template',
                   default='/pawsey/centos7.6/apps/gcc/4.8.5/python/3.6.3/bin/python')               
    args = p.parse_args()

    # Setup args
    plugin = os.path.splitext(args.plugin_name)[0]
    srcdir = os.path.dirname(plugin)
    plugin = os.path.basename(plugin)
    if os.system(f'{args.pybin} -V') == 0: 
        pybin  = args.pybin
    else:
        print(f"WARNING: Could not find Python executable {args.pybin}. Trying default 'python'")
        pybin = 'python'

    if os.path.exists(f'{srcdir}/{plugin}.h') and os.path.exists(args.outdir):
        print(f"Generating {plugin}_generated.py...")
        generate_and_patch(plugin, inc_dir, pybin, outdir=args.outdir, srcdir=srcdir)
    else:
        print(f"Error: could not find {plugin}.h and/or {args.outdir}")
        sys.exit(-1)
