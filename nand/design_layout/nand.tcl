# Magic VLSI Layout Generator for CMOS NAND Gate
# Technology: SKY130A
# 
# This script generates a complete layout for a 2-input NAND gate
# with proper DRC compliance and port definitions

# ============================================
# UTILITY FUNCTIONS
# ============================================

# Custom floor function that handles integer and floating point values correctly
proc custom_floor {value} {
    set integer_part [expr {int($value)}]
    if {$value == $integer_part} {
        return $integer_part
    } elseif {$value > 0} {
        return $integer_part
    } else {
        expr {$integer_part - 1}
    }
}

# Draw a text label at specified coordinates
proc draw_text_label {x_coord y_coord label_text} {
    if {$label_text != ""} {
        box [expr $x_coord - 0.1]um [expr $y_coord - 0.1]um \
            [expr $x_coord + 0.1]um [expr $y_coord + 0.1]um
        label $label_text FreeSans 60
    }
}

# Paint a rectangular box on specified layer
proc paint_rectangle {x_coord y_coord width height layer_name} {
    box [expr $x_coord]um [expr $y_coord]um \
        [expr $x_coord + $width]um [expr $y_coord + $height]um
    paint $layer_name
}

# ============================================
# INITIALIZATION AND TECHNOLOGY SETUP
# ============================================

# Global counter for port numbering
set global_port_counter 1

# Load technology and set up grid
#tech load sky130A
drc off
snap internal
grid 0.005um 0.005um

# ============================================
# DESIGN RULE PARAMETERS (from SKY130A)
# ============================================

# Basic dimensions
set lambda_value 0.005               
# Lambda scaling unit
set min_diffusion_width 0.15         
# Minimum diffusion width
set min_poly_width 0.15               
set poly_width $min_poly_width
# Minimum poly width
set contact_size 0.17                 
# Contact/via size
set li_extension 0.08                  
# Local interconnect extension

# Spacing rules
set li_spacing 0.17                   
# Local interconnect spacing (li.3)
set contact_spacing 0.17               
# Contact spacing
set contact_poly_spacing 0.15          
# Contact to poly spacing
set poly_spacing 0.21                   
# Poly to poly spacing (poly.2)
set poly_diffusion_spacing 0.075       
# Poly to diffusion spacing (poly.4)
set diffusion_spacing 0.27              
# Diffusion to diffusion spacing (diff/tap.3)
set ndiff_nwell_spacing 0.34            
# N-diffusion to N-well spacing (diff/tap.9)

# Enclosure rules
set contact_diffusion_enclosure 0.1     
# Contact enclosure by diffusion
set contact_poly_enclosure 0.1          
# Contact enclosure by poly
set diffusion_nwell_enclosure 0.18      
# Diffusion enclosure by N-well (diff/tap.10)
set tap_diffusion_nwell_enclosure 0.18  
# Tap diffusion enclosure by N-well

# Derived dimensions
set single_contact_li_width [expr $contact_size + 2 * $li_extension]
set single_contact_poly_width [expr $contact_size + 2 * $contact_poly_enclosure]
set single_contact_diffusion_width [expr $contact_size + 2 * $contact_diffusion_enclosure]
set single_contact_tap_width [expr $contact_size + 2 * $contact_diffusion_enclosure] 
# Using same as diffusion
set poly_extension 0.17

# Finger/spacing parameters
set finger_width $poly_spacing
set contact_finger_width [expr $contact_size + 2 * $contact_poly_spacing]
set contact_tap_diffusion_enclosure 0.1

# ============================================
# TRANSISTOR GENERATION FUNCTIONS
# ============================================

# Basic transistor with single gate and bulk connection
# Parameters:
#   x, y: bottom-left corner coordinates
#   channel_width: transistor width (W)
#   channel_length: transistor length (L)
#   device_type: "nmos" or "pmos"
# Returns: list of key coordinates [gate_x gate_y drain_contact_x drain_contact_y]
proc draw_basic_transistor {x_coord y_coord channel_width channel_length device_type} {
    global li_spacing contact_diffusion_enclosure contact_size contact_poly_spacing
    global li_extension single_contact_li_width poly_width poly_extension
    global contact_poly_enclosure single_contact_poly_width
    global single_contact_diffusion_width diffusion_spacing
    global diffusion_nwell_enclosure contact_spacing global_port_counter

   
# Set layer names based on device type
    if {$device_type == "nmos"} {
        set diffusion_layer "ndiff"
        set diffusion_contact_layer "ndiffc"
        set substrate_layer "psubdiff"
        set substrate_contact_layer "psubdiffc"
        set substrate_label "VSS"
        set port_number 5
    } else {
        set diffusion_layer "pdiff"
        set diffusion_contact_layer "pdiffc"
        set substrate_layer "nsubdiff"
        set substrate_contact_layer "nsubdiffc"
        set substrate_label "VDD"
        set port_number 4
    }

   
# ===== DIFFUSION REGION =====
    set diffusion_poly_side [expr $contact_diffusion_enclosure + $contact_size + $contact_poly_spacing]
    set diffusion_height [expr $channel_width]
    set diffusion_width [expr $channel_length + 2 * $diffusion_poly_side]
    
    paint_rectangle $x_coord $y_coord $diffusion_width $diffusion_height $diffusion_layer

   
# ===== GATE (POLY) =====
    set gate_x [expr $x_coord + $diffusion_poly_side]
    set gate_y [expr $y_coord - $poly_extension]
    set gate_width $poly_width
    set gate_height [expr 2 * $poly_extension + $diffusion_height]
    paint_rectangle $gate_x $gate_y $gate_width $gate_height "poly"

   
# ===== SOURCE/DRAIN CONTACTS =====
   
# Calculate number of contacts needed based on diffusion height
    set num_contacts [custom_floor [expr ($diffusion_height - 2 * $contact_diffusion_enclosure + $contact_spacing) / ($contact_size + $contact_spacing)]]
    set contact_offset [expr ($diffusion_height - $contact_size * $num_contacts - $contact_spacing * ($num_contacts - 1)) / 2.0]
    
   
# Source contacts (left side)
    set source_contact_x [expr $x_coord + $contact_diffusion_enclosure]
    set source_contact_y [expr $y_coord + $contact_offset]
    
    for {set i 0} {$i < $num_contacts} {incr i} {
        paint_rectangle $source_contact_x $source_contact_y $contact_size $contact_size $diffusion_contact_layer
        set source_contact_y [expr $source_contact_y + $contact_spacing + $contact_size]
    }

   
# Drain contacts (right side)
    set drain_contact_x [expr $x_coord + $diffusion_width - $contact_diffusion_enclosure - $contact_size]
    set drain_contact_y [expr $y_coord + $contact_offset]
    
    for {set i 0} {$i < $num_contacts} {incr i} {
        paint_rectangle $drain_contact_x $drain_contact_y $contact_size $contact_size $diffusion_contact_layer
        set drain_contact_y [expr $drain_contact_y + $contact_spacing + $contact_size]
    }

   
# ===== BULK/SUBSTRATE CONNECTION =====
    set bulk_width $single_contact_diffusion_width
    set bulk_x $x_coord
    
    if {$device_type == "nmos"} {
        set bulk_y [expr $y_coord - $diffusion_spacing - $bulk_width]
    } else {
        set bulk_y [expr $y_coord + $diffusion_height + $diffusion_spacing]
    }
    
    paint_rectangle $bulk_x $bulk_y $bulk_width $bulk_width $substrate_layer
    
   
# Bulk contact
    set bulk_contact_x [expr $bulk_x + $contact_diffusion_enclosure]
    set bulk_contact_y [expr $bulk_y + $contact_diffusion_enclosure]
    paint_rectangle $bulk_contact_x $bulk_contact_y $contact_size $contact_size $substrate_contact_layer

   
# ===== LOCAL INTERCONNECT (LI) FOR SOURCE-BULK CONNECTION =====
    set li_width $single_contact_li_width
    
    if {$device_type == "nmos"} {
        set bulk_source_height [expr $y_coord + $diffusion_height - $contact_offset - $contact_size - $bulk_contact_y]
        set li_y1 [expr $source_contact_y - $bulk_source_height - $li_extension - $contact_size * $num_contacts - $contact_spacing * ($num_contacts - 1)]
    } else {
        set bulk_source_height [expr $bulk_contact_y - ($y_coord + $contact_offset)]
        set li_y1 [expr $y_coord + $contact_offset - $li_extension]
    }
    
    set li_x1 [expr $source_contact_x - $li_extension]
    set li_height [expr $bulk_source_height + $single_contact_li_width]
    paint_rectangle $li_x1 $li_y1 $li_width $li_height "li"
    
   
# Horizontal LI for bulk
    set li_x2 [expr $bulk_contact_x - $li_extension]
    set li_y2 [expr $bulk_contact_y - $li_extension]
    paint_rectangle $li_x2 $li_y2 $li_height $li_width "li"
    
   
# Add power label
    label $substrate_label FreeSans 60
    port make $port_number

   
# ===== N-WELL FOR PMOS =====
    if {$device_type == "pmos"} {
        set nwell_width [expr $diffusion_width + 2 * $diffusion_nwell_enclosure]
        set nwell_height [expr $diffusion_height + 2 * $diffusion_nwell_enclosure + $diffusion_spacing + $bulk_width]
        set nwell_x [expr $x_coord - $diffusion_nwell_enclosure]
        set nwell_y [expr $y_coord - $diffusion_nwell_enclosure]
        paint_rectangle $nwell_x $nwell_y $nwell_width $nwell_height "nwell"
    }

   
# Return key coordinates for routing
    if {$device_type == "nmos"} {
        return [list $gate_x [expr $gate_y + $gate_height] $drain_contact_x [expr $y_coord + $contact_offset]]
    } else {
        return [list $gate_x $gate_y $drain_contact_x [expr $y_coord + $diffusion_height - $contact_offset - $contact_size]]
    }
}

# Multi-finger transistor with shared source/drain
# Parameters:
#   x, y: bottom-left corner coordinates
#   channel_width: total transistor width (W)
#   channel_length: transistor length (L)
#   num_fingers: number of gate fingers
#   device_type: "nmos" or "pmos"
proc draw_finger_transistor {x_coord y_coord channel_width channel_length num_fingers device_type} {
    global li_spacing contact_diffusion_enclosure contact_size contact_poly_spacing
    global li_extension single_contact_li_width poly_width poly_extension
    global contact_poly_enclosure single_contact_poly_width
    global single_contact_diffusion_width diffusion_spacing
    global diffusion_nwell_enclosure contact_spacing finger_width
    global single_contact_tap_width contact_tap_diffusion_enclosure global_port_counter

   
# Set layer names based on device type
    if {$device_type == "nmos"} {
        set diffusion_layer "ndiff"
        set diffusion_contact_layer "ndiffc"
        set substrate_layer "psubdiff"
        set substrate_contact_layer "psubdiffc"
        set substrate_label "VSS"
        set port_number 5
    } else {
        set diffusion_layer "pdiff"
        set diffusion_contact_layer "pdiffc"
        set substrate_layer "nsubdiff"
        set substrate_contact_layer "nsubdiffc"
        set substrate_label "VDD"
        set port_number 4
    }

   
# ===== DIFFUSION REGION (with fingers) =====
    set diffusion_poly_side [expr $contact_diffusion_enclosure + $contact_size + $contact_poly_spacing]
    set diffusion_height [expr $channel_width]
    set diffusion_width [expr ($num_fingers - 1) * $finger_width + $poly_width * $num_fingers + 2 * $diffusion_poly_side]
    
    paint_rectangle $x_coord $y_coord $diffusion_width $diffusion_height $diffusion_layer

   
# ===== SOURCE CONTACTS (left side) =====
    set num_contacts [custom_floor [expr ($diffusion_height - 2 * $contact_diffusion_enclosure + $contact_spacing) / ($contact_size + $contact_spacing)]]
    set contact_offset [expr ($diffusion_height - $contact_size * $num_contacts - $contact_spacing * ($num_contacts - 1)) / 2.0]
    
    set source_contact_x [expr $x_coord + $contact_diffusion_enclosure]
    set source_contact_y [expr $y_coord + $contact_offset]
    
    for {set i 0} {$i < $num_contacts} {incr i} {
        paint_rectangle $source_contact_x $source_contact_y $contact_size $contact_size $diffusion_contact_layer
        set source_contact_y [expr $source_contact_y + $contact_spacing + $contact_size]
    }

   
# ===== MULTIPLE GATES (POLY FINGERS) =====
    set gate_height [expr 2 * $poly_extension + $diffusion_height]
    set gate_x [expr $x_coord + $diffusion_poly_side]
    set gate_y [expr $y_coord - $poly_extension]
    set finger_pitch [expr $poly_width + $finger_width]
    
    for {set finger 0} {$finger < $num_fingers} {incr finger} {
        paint_rectangle $gate_x $gate_y $poly_width $gate_height "poly"
        set gate_x [expr $gate_x + $finger_pitch]
    }

   
# ===== DRAIN CONTACTS (right side) =====
    set drain_contact_x [expr $x_coord + $diffusion_width - $contact_diffusion_enclosure - $contact_size]
    set drain_contact_y [expr $y_coord + $contact_offset]
    
    for {set i 0} {$i < $num_contacts} {incr i} {
        paint_rectangle $drain_contact_x $drain_contact_y $contact_size $contact_size $diffusion_contact_layer
        set drain_contact_y [expr $drain_contact_y + $contact_spacing + $contact_size]
    }

   
# ===== BULK/SUBSTRATE CONNECTION =====
    set bulk_height $single_contact_tap_width
    set bulk_width $diffusion_width
    set tap_num_contacts [custom_floor [expr ($diffusion_width - 2 * $contact_tap_diffusion_enclosure + $contact_spacing) / ($contact_size + $contact_spacing)]]
    set tap_contact_offset [expr ($diffusion_width - $contact_size * $tap_num_contacts - $contact_spacing * ($tap_num_contacts - 1)) / 2.0]
    
    set bulk_x $x_coord
    if {$device_type == "nmos"} {
        set bulk_y [expr $y_coord - $diffusion_spacing - $bulk_height]
    } else {
        set bulk_y [expr $y_coord + $diffusion_height + $diffusion_spacing]
    }
    
    paint_rectangle $bulk_x $bulk_y $bulk_width $bulk_height $substrate_layer
    
   
# Bulk contacts (distributed along width)
    set bulk_contact_x [expr $bulk_x + $tap_contact_offset]
    set bulk_contact_y [expr $bulk_y + $contact_tap_diffusion_enclosure]
    
    for {set i 0} {$i < $tap_num_contacts} {incr i} {
        paint_rectangle $bulk_contact_x $bulk_contact_y $contact_size $contact_size $substrate_contact_layer
        set bulk_contact_x [expr $bulk_contact_x + $contact_size + $contact_spacing]
    }

   
# ===== LOCAL INTERCONNECT (LI) =====
    set li_width $single_contact_li_width
    
   
# Vertical LI connecting source to bulk
    if {$device_type == "nmos"} {
        #set bulk_source_height [expr $y_coord + $diffusion_height - $contact_offset - $contact_size - $bulk_contact_y + $contact_spacing * ($tap_num_contacts - 1)]
        set bulk_source_height [expr $y_coord + $diffusion_height - $contact_offset -$contact_size - $bulk_contact_y ]
        #set li_y1 [expr $source_contact_y - $bulk_source_height - $li_extension - $contact_size * $num_contacts - $contact_spacing * ($num_contacts - 1)]
        set li_y1 [expr $bulk_contact_y - $li_extension ]
    } else {
        set bulk_source_height [expr $bulk_contact_y - ($y_coord + $contact_offset)]
        set li_y1 [expr $y_coord + $contact_offset - $li_extension]
    }
    
    set li_x1 [expr $source_contact_x - $li_extension]
    set li_height [expr $bulk_source_height + $single_contact_li_width]
    paint_rectangle $li_x1 $li_y1 $li_width $li_height "li"
    
   
# Horizontal LI across bulk region
    set li_x2 $x_coord
    set li_y2 [expr $bulk_contact_y - $li_extension]
    paint_rectangle $li_x2 $li_y2 $diffusion_width $single_contact_li_width "li"
    
   
# Add power label
    label $substrate_label FreeSans 60
    port make $port_number

   
# ===== N-WELL FOR PMOS =====
    if {$device_type == "pmos"} {
        set nwell_width [expr $diffusion_width + 2 * $diffusion_nwell_enclosure]
        set nwell_height [expr $diffusion_height + 2 * $diffusion_nwell_enclosure + $diffusion_spacing + $bulk_height]
        set nwell_x [expr $x_coord - $diffusion_nwell_enclosure]
        set nwell_y [expr $y_coord - $diffusion_nwell_enclosure]
        paint_rectangle $nwell_x $nwell_y $nwell_width $nwell_height "nwell"
    }

   
# Return key coordinates for routing
    set gate1_x [expr $x_coord + $diffusion_poly_side]
    set gate2_x [expr $x_coord + $diffusion_poly_side + $finger_pitch]
    
    if {$device_type == "nmos"} {
        set gate1_y [expr $y_coord - $poly_extension + $gate_height]
        set drain_y [expr $y_coord + $contact_offset]
        return [list $gate1_x $gate1_y $gate2_x $drain_contact_x $drain_y]
    } else {
        set gate1_y [expr $y_coord - $poly_extension]
        set drain_y [expr $y_coord + $diffusion_height - $contact_offset - $contact_size]
        return [list $gate1_x $gate1_y $gate2_x $drain_contact_x $drain_y]
    }
}

# Advanced multi-finger transistor with contacts between gates
# Used for PMOS in NAND to provide both drain connections
proc draw_contact_finger_transistor {x_coord y_coord channel_width channel_length num_fingers device_type} {
    global li_spacing contact_diffusion_enclosure contact_size contact_poly_spacing
    global li_extension single_contact_li_width poly_width poly_extension
    global contact_poly_enclosure single_contact_poly_width
    global single_contact_diffusion_width diffusion_spacing
    global diffusion_nwell_enclosure contact_spacing contact_finger_width
    global single_contact_tap_width contact_tap_diffusion_enclosure global_port_counter

   
# Set layer names based on device type
    if {$device_type == "nmos"} {
        set diffusion_layer "ndiff"
        set diffusion_contact_layer "ndiffc"
        set substrate_layer "psubdiff"
        set substrate_contact_layer "psubdiffc"
        set substrate_label "VSS"
        set port_number 5
    } else {
        set diffusion_layer "pdiff"
        set diffusion_contact_layer "pdiffc"
        set substrate_layer "nsubdiff"
        set substrate_contact_layer "nsubdiffc"
        set substrate_label "VDD"
        set port_number 4
    }

   
# ===== DIFFUSION REGION =====
    set diffusion_poly_side [expr $contact_diffusion_enclosure + $contact_size + $contact_poly_spacing]
    set diffusion_height [expr $channel_width]
    set diffusion_width [expr ($num_fingers - 1) * $contact_finger_width + $poly_width * $num_fingers + 2 * $diffusion_poly_side]
    
    paint_rectangle $x_coord $y_coord $diffusion_width $diffusion_height $diffusion_layer

   
# ===== SOURCE CONTACTS (left side) =====
    set num_contacts [custom_floor [expr ($diffusion_height - 2 * $contact_diffusion_enclosure + $contact_spacing) / ($contact_size + $contact_spacing)]]
    set contact_offset [expr ($diffusion_height - $contact_size * $num_contacts - $contact_spacing * ($num_contacts - 1)) / 2.0]
    
    set source_contact_x [expr $x_coord + $contact_diffusion_enclosure]
    set source_contact_y [expr $y_coord + $contact_offset]
    
    for {set i 0} {$i < $num_contacts} {incr i} {
        paint_rectangle $source_contact_x $source_contact_y $contact_size $contact_size $diffusion_contact_layer
        set source_contact_y [expr $source_contact_y + $contact_spacing + $contact_size]
    }

   
# ===== GATES AND INTER-GATE CONTACTS =====
    set gate_height [expr 2 * $poly_extension + $diffusion_height]
    set gate_x [expr $x_coord + $diffusion_poly_side]
    set gate_y [expr $y_coord - $poly_extension]
    set finger_pitch [expr $poly_width + $contact_finger_width]
    
    for {set finger 0} {$finger < $num_fingers} {incr finger} {
       
# Draw gate
        paint_rectangle $gate_x $gate_y $poly_width $gate_height "poly"
        
       
# Draw contacts between gates (for shared drain)
        set inter_gate_contact_x [expr $gate_x + $poly_width + $contact_poly_spacing]
        set inter_gate_contact_y [expr $y_coord + $contact_offset]
        
        for {set i 0} {$i < $num_contacts} {incr i} {
            paint_rectangle $inter_gate_contact_x $inter_gate_contact_y $contact_size $contact_size $diffusion_contact_layer
            set inter_gate_contact_y [expr $inter_gate_contact_y + $contact_spacing + $contact_size]
        }
        
        set gate_x [expr $gate_x + $finger_pitch]
    }

   
# ===== BULK/SUBSTRATE CONNECTION =====
    set bulk_height $single_contact_tap_width
    set bulk_width $diffusion_width
    set tap_num_contacts [custom_floor [expr ($diffusion_width - 2 * $contact_tap_diffusion_enclosure + $contact_spacing) / ($contact_size + $contact_spacing)]]
    set tap_contact_offset [expr ($diffusion_width - $contact_size * $tap_num_contacts - $contact_spacing * ($tap_num_contacts - 1)) / 2.0]
    
    set bulk_x $x_coord
    if {$device_type == "nmos"} {
        set bulk_y [expr $y_coord - $diffusion_spacing - $bulk_height]
    } else {
        set bulk_y [expr $y_coord + $diffusion_height + $diffusion_spacing]
    }
    
    paint_rectangle $bulk_x $bulk_y $bulk_width $bulk_height $substrate_layer
    
   
# Bulk contacts
    set bulk_contact_x [expr $bulk_x + $tap_contact_offset]
    set bulk_contact_y [expr $bulk_y + $contact_tap_diffusion_enclosure]
    
    for {set i 0} {$i < $tap_num_contacts} {incr i} {
        paint_rectangle $bulk_contact_x $bulk_contact_y $contact_size $contact_size $substrate_contact_layer
        set bulk_contact_x [expr $bulk_contact_x + $contact_size + $contact_spacing]
    }

   
# ===== LOCAL INTERCONNECT (LI) =====
    set li_width $single_contact_li_width
    
   
# Left vertical LI
    if {$device_type == "nmos"} {
        set bulk_source_height [expr $y_coord + $diffusion_height - $contact_offset - $contact_size - $bulk_contact_y + $contact_spacing * ($tap_num_contacts - 1)]
        set li_y1 [expr $source_contact_y - $bulk_source_height - $li_extension - $contact_size * $num_contacts - $contact_spacing * ($num_contacts - 1)]
    } else {
        set bulk_source_height [expr $bulk_contact_y - ($y_coord + $contact_offset)]
        set li_y1 [expr $y_coord + $contact_offset - $li_extension]
    }
    
    set li_x1 [expr $source_contact_x - $li_extension]
    set li_height [expr $bulk_source_height + $single_contact_li_width]
    paint_rectangle $li_x1 $li_y1 $li_width $li_height "li"
    
   
# Right vertical LI (for NAND PMOS to connect both drains)
    set li_x3 [expr $x_coord + $diffusion_width - $contact_diffusion_enclosure - $contact_size - $li_extension]
    if {$device_type == "nmos"} {
        set li_y3 [expr $source_contact_y - $bulk_source_height - $li_extension]
    } else {
        set li_y3 [expr $y_coord + $contact_offset - $li_extension]
    }
    paint_rectangle $li_x3 $li_y3 $li_width $li_height "li"
    
   
# Horizontal LI for bulk
    set li_x2 $x_coord
    set li_y2 [expr $bulk_contact_y - $li_extension]
    paint_rectangle $li_x2 $li_y2 $diffusion_width $single_contact_li_width "li"
    
   
# Add power label
    label $substrate_label FreeSans 60
    port make $port_number

   
# ===== N-WELL FOR PMOS =====
    if {$device_type == "pmos"} {
        set nwell_width [expr $diffusion_width + 2 * $diffusion_nwell_enclosure]
        set nwell_height [expr $diffusion_height + 2 * $diffusion_nwell_enclosure + $diffusion_spacing + $bulk_height]
        set nwell_x [expr $x_coord - $diffusion_nwell_enclosure]
        set nwell_y [expr $y_coord - $diffusion_nwell_enclosure]
        paint_rectangle $nwell_x $nwell_y $nwell_width $nwell_height "nwell"
    }

   
# Return key coordinates for routing
    set gate1_x [expr $x_coord + $diffusion_poly_side]
    set gate2_x [expr $x_coord + $diffusion_poly_side + $finger_pitch]
    set inter_gate_contact_x [expr $x_coord + $diffusion_poly_side + $poly_width + $contact_poly_spacing]
    
    if {$device_type == "nmos"} {
        set gate1_y [expr $y_coord - $poly_extension + $gate_height]
        set drain_y [expr $y_coord + $contact_offset]
        return [list $gate1_x $gate1_y $gate2_x $inter_gate_contact_x $drain_y]
    } else {
        set gate1_y [expr $y_coord - $poly_extension]
        set drain_y [expr $y_coord + $diffusion_height - $contact_offset - $contact_size]
        return [list $gate1_x $gate1_y $gate2_x $inter_gate_contact_x $drain_y]
    }
}

# ============================================
# ROUTING UTILITIES
# ============================================

# Create a poly-to-local-interconnect connection
# Parameters:
#   center_x, center_y: connection point coordinates
proc create_poly_to_li_contact {center_x center_y} {
    global single_contact_poly_width single_contact_li_width contact_size
    
    set poly_x [expr $center_x - $single_contact_poly_width / 2]
    set poly_y [expr $center_y - $single_contact_poly_width / 2]
    paint_rectangle $poly_x $poly_y $single_contact_poly_width $single_contact_poly_width "poly"
    
    set licon_x [expr $center_x - $contact_size / 2]
    set licon_y [expr $center_y - $contact_size / 2]
    paint_rectangle $licon_x $licon_y $contact_size $contact_size "pc"
    
    set li_x [expr $center_x - $single_contact_li_width / 2]
    set li_y [expr $center_y - $single_contact_li_width / 2]
    paint_rectangle $li_x $li_y $single_contact_li_width $single_contact_li_width "li"
}

# ============================================
# MAIN NAND GATE GENERATOR
# ============================================

# Generate complete 2-input NAND gate layout
# Parameters:
#   x_offset, y_offset: placement coordinates
proc generate_nand_gate {x_offset y_offset} {
    global contact_diffusion_enclosure contact_size contact_poly_spacing
    global li_extension poly_width single_contact_li_width
    global single_contact_poly_width diffusion_nwell_enclosure
    global ndiff_nwell_spacing global_port_counter

   
# ===== PMOS TRANSISTORS (pull-up network) =====
    set pmos_width 1.0
    set pmos_length 0.15
    
   
# Draw 2-finger PMOS (series connection for NAND)
    lassign [draw_contact_finger_transistor $x_offset $y_offset $pmos_width $pmos_length 2 "pmos"] \
        pmos_gate1_x pmos_gate1_y pmos_gate2_x pmos_drain_x pmos_drain_y

   
# ===== NMOS TRANSISTORS (pull-down network) =====
    set nmos_width 1.0
    set nmos_length 0.15
    
   
# Calculate NMOS position (below PMOS with proper spacing)
    set nmos_diffusion_side [expr $contact_diffusion_enclosure + $contact_size + $contact_poly_spacing]
    set nmos_diffusion_height [expr $nmos_length + 2 * $nmos_diffusion_side]
    set nmos_y [expr $y_offset - $diffusion_nwell_enclosure - $ndiff_nwell_spacing - $nmos_width]
    
   
# Draw 2-finger NMOS (series connection for NAND)
    lassign [draw_finger_transistor $x_offset $nmos_y $nmos_width $nmos_length 2 "nmos"] \
        nmos_gate1_x nmos_gate1_y nmos_gate2_x nmos_drain_x nmos_drain_y

   
# ===== INTERMEDIATE NODE LABEL =====
    set intermediate_x [expr ($nmos_gate1_x + $nmos_gate2_x) / 2.0 + $poly_width / 2]
    set intermediate_y [expr $y_offset - $diffusion_nwell_enclosure - $ndiff_nwell_spacing - $nmos_width / 2.0]
    draw_text_label $intermediate_x $intermediate_y "net1"

   
# ===== GATE CONNECTIONS =====
   
# First input (A) - connects to first NMOS gate and first PMOS gate
    paint_rectangle $nmos_gate1_x $nmos_gate1_y $poly_width [expr $pmos_gate1_y - $nmos_gate1_y] "poly"
    
    set input_a_x [expr $nmos_gate1_x - 0.8]
    set input_a_y $nmos_gate1_y
    
    paint_rectangle $input_a_x [expr $input_a_y - $poly_width / 2.0] \
                   [expr $nmos_gate1_x - $input_a_x] $poly_width "poly"
    
    create_poly_to_li_contact $input_a_x $input_a_y
    label "A" FreeSans 60
    port make $global_port_counter
    set global_port_counter [expr $global_port_counter + 1]

   
# Second input (B) - connects to second NMOS gate and second PMOS gate
   
# Uses a "staircase" poly routing to connect both transistors
    set poly_ratio 0.4
    set bend_y [expr $nmos_gate1_y + ($pmos_gate1_y - $nmos_gate1_y) * $poly_ratio]
    
   
# Vertical up from NMOS
    paint_rectangle $nmos_gate2_x $nmos_gate1_y $poly_width [expr $bend_y - $nmos_gate1_y] "poly"
   
# Horizontal segment
    paint_rectangle $nmos_gate2_x $bend_y [expr $pmos_gate2_x - $nmos_gate2_x + $poly_width] $poly_width "poly"
   
# Vertical down to PMOS
    paint_rectangle $pmos_gate2_x $bend_y $poly_width [expr $pmos_gate1_y - $bend_y] "poly"
    
    set input_b_x [expr $nmos_gate2_x + 1.1]
    set input_b_y $bend_y
    paint_rectangle [expr $pmos_gate2_x - $poly_width] [expr $input_b_y - $poly_width / 2.0] \
                   [expr $input_b_x - $pmos_gate2_x] $poly_width "poly"
    
    create_poly_to_li_contact $input_b_x $input_b_y
    label "B" FreeSans 60
    port make $global_port_counter
    set global_port_counter [expr $global_port_counter + 1]

   
# ===== OUTPUT CONNECTION (Y) =====
   
# Connect NMOS drains to PMOS drains using LI
    set routing_ratio 0.5
    set output_bend_y [expr $nmos_drain_y + ($pmos_drain_y - $nmos_drain_y) * $routing_ratio]
    
   
# Vertical from NMOS drain
    paint_rectangle [expr $nmos_drain_x - $li_extension] \
                   [expr $nmos_drain_y - $li_extension] \
                   $single_contact_li_width \
                   [expr $output_bend_y - $nmos_drain_y + $single_contact_li_width] "li"
    
   
# Horizontal connection
    set pmos_drain_x_adj $pmos_drain_x
    paint_rectangle [expr $pmos_drain_x - $li_extension] \
                   [expr $output_bend_y - $li_extension] \
                   [expr $nmos_drain_x - $pmos_drain_x + $single_contact_li_width] \
                   $single_contact_li_width "li"
    
   
# Vertical to PMOS drain
    paint_rectangle [expr $pmos_drain_x - $li_extension] \
                   [expr $output_bend_y - $li_extension] \
                   $single_contact_li_width \
                   [expr $pmos_drain_y - $output_bend_y + $single_contact_li_width] "li"
    
    label "Y" FreeSans 60
    port make $global_port_counter
    set global_port_counter [expr $global_port_counter + 1]
}

# ============================================
# MAIN EXECUTION
# ============================================

# Load existing layout or create new
load nand -force

# Generate the NAND gate at origin (0,0)
generate_nand_gate 0 0

# Save the layout
save

# Exit Magic
quit
