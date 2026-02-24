#flatten blog_post_flat
#load blog_post_flat
#cellname delete blog_post
#cellname rename blog_post_flat blog_post
#select top cell
#extract do local
magic_sky130a -dnull -noconsole buf.mag << EOF
extract all
ext2sim labels on
ext2sim
extresist tolerance 10
extresist
ext2spice lvs
ext2spice thresh 0
ext2spice cthresh 0
ext2spice rthresh 0
ext2spice extresist on
ext2spice -o buf_pex.spice
EOF
ngspice tb_buf_pex.spice
