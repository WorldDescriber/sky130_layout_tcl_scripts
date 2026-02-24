################################################################################
# Sky130 PDK-based CMOS Buffer Cell Layout Generator
# 
# This script generates a complete buffer (two inverters in series) layout
# using Sky130 design rules.
# Cells: Single transistor, Inverter, Buffer with A input and Y output
################################################################################

#===============================================================================
# UTILITY FUNCTIONS
#===============================================================================

# Custom floor function for integer calculations
proc floor_value {x} {
    set int_x [expr {int($x)}]
    if {$x == $int_x} {
        return $int_x
    } elseif {$x > 0} {
        return $int_x
    } else {
        expr {$int_x - 1}
    }
}

# Draw a label with a bounding box
proc draw_label_with_box {label_x label_y label_text} {
    if {$label_text != ""} {
        box [expr $label_x - 0.1]um [expr $label_y - 0.1]um \
            [expr $label_x + 0.1]um [expr $label_y + 0.1]um
        label $label_text FreeSans 60
    }
}

# Paint a rectangle with given dimensions
proc paint_rectangle {x y width height layer} {
    box [expr $x]um [expr $y]um [expr $x+$width]um [expr $y+$height]um
    paint $layer
}

#===============================================================================
# SKY130 DESIGN RULES
# Source: http://skywater.ai/docs/pdk
#===============================================================================

# Basic dimensions
set lambda 0.005                ;# Lambda scaling factor (grid unit)

# Minimum feature sizes
set min_diffusion_width 0.15    ;# Minimum diffusion width
set min_poly_width 0.15         ;# Minimum poly width
set min_diffusion_spacing 0.27  ;# Minimum spacing between diffusion regions

# Contact/via rules
set contact_size 0.17           ;# Contact/via size
set contact_spacing 0.17        ;# Spacing between contacts
set contact_to_poly_spacing 0.15 ;# Spacing from contact to poly

# Diffusion enclosure rules
set contact_diffusion_enclosure 0.1   ;# Diffusion enclosure around contact
set contact_poly_enclosure 0.1        ;# Poly enclosure around contact
set contact_tap_enclosure 0.1         ;# Tap diffusion enclosure around contact

# Poly rules
set poly_extension_over_diffusion 0.15 ;# Poly extension beyond diffusion

# Well rules
set nwell_to_diffusion_spacing 0.34    ;# N-well to P-diffusion spacing
set diffusion_to_nwell_enclosure 0.18  ;# Diffusion enclosure by N-well
set tap_to_nwell_enclosure 0.18        ;# Tap diffusion enclosure by N-well
set nwell_spacing 1.27                 ;# Spacing between N-wells
set nwell_min_width 0.84               ;# Minimum N-well width

# Local interconnect (LI) rules
set li_spacing 0.17                    ;# LI spacing
set li_contact_extension 0.08          ;# LI extension beyond contact

# Derived dimensions
set contact_with_li_width [expr $contact_size + 2*$li_contact_extension]
set contact_with_poly_width [expr $contact_size + 2*$contact_poly_enclosure]
set contact_with_diffusion_width [expr $contact_size + 2*$contact_diffusion_enclosure]
set contact_with_tap_width [expr $contact_size + 2*$contact_tap_enclosure]
set poly_to_contact_space [expr $contact_size + 2*$contact_to_poly_spacing]

#===============================================================================
# TRANSISTOR GENERATION
#===============================================================================

# Draw a single-finger transistor
# Parameters:
#   x, y: Bottom-left corner of diffusion
#   width: Transistor width (W)
#   length: Transistor length (L)
#   device_type: "nmos" or "pmos"
# Returns: List of key coordinates [gate_x gate_y drain_x drain_y bulk_y]
proc draw_single_transistor {x y width length device_type} {
    global contact_diffusion_enclosure contact_size
    global contact_to_poly_spacing li_contact_extension contact_with_li_width
    global poly_extension_over_diffusion
    global min_diffusion_spacing contact_spacing contact_tap_enclosure
    global contact_with_tap_width diffusion_to_nwell_enclosure
    global min_poly_width
    set poly_width $min_poly_width

    # Select layers based on device type
    if {$device_type == "nmos"} {
        set diffusion_layer "ndiff"
        set contact_layer "ndiffc"
        set substrate_layer "psubdiff"
        set substrate_contact_layer "psubdiffc"
    } else {
        set diffusion_layer "pdiff"
        set contact_layer "pdiffc"
        set substrate_layer "nsubdiff"
        set substrate_contact_layer "nsubdiffc"
    }

    # Diffusion region dimensions
    set diffusion_side_width [expr $contact_diffusion_enclosure + $contact_size + $contact_to_poly_spacing]
    set diffusion_width [expr $length + 2*$diffusion_side_width]
    
    # Draw main diffusion
    paint_rectangle $x $y $diffusion_width $width $diffusion_layer

    # Calculate number of source/drain contacts
    set num_contacts [floor_value [expr ($width - 2*$contact_diffusion_enclosure + $contact_spacing) / ($contact_size + $contact_spacing)]]
    set contact_offset [expr ($width - $contact_size*$num_contacts - $contact_spacing*($num_contacts-1)) / 2.0]

    # Draw source contacts (left side)
    set source_x [expr $x + $contact_diffusion_enclosure]
    set source_y [expr $y + $contact_offset]
    for {set i 0} {$i < $num_contacts} {incr i} {
        paint_rectangle $source_x $source_y $contact_size $contact_size $contact_layer
        set source_y [expr $source_y + $contact_size + $contact_spacing]
    }

    # Draw gate poly
    set gate_x [expr $x + $diffusion_side_width]
    set gate_y [expr $y - $poly_extension_over_diffusion]
    set gate_height [expr 2*$poly_extension_over_diffusion + $width]
    paint_rectangle $gate_x $gate_y $poly_width $gate_height "poly"

    # Draw drain contacts (right side)
    set drain_x [expr $x + $diffusion_width - $contact_diffusion_enclosure - $contact_size]
    set drain_y [expr $y + $contact_offset]
    for {set i 0} {$i < $num_contacts} {incr i} {
        paint_rectangle $drain_x $drain_y $contact_size $contact_size $contact_layer
        set drain_y [expr $drain_y + $contact_size + $contact_spacing]
    }

    # Draw bulk/substrate tap diffusion
    set bulk_width [expr $diffusion_width]
    set bulk_height [expr $contact_with_tap_width]
    if {$device_type == "nmos"} {
        set bulk_y [expr $y - $min_diffusion_spacing - $bulk_height]
    } else {
        set bulk_y [expr $y + $width + $min_diffusion_spacing]
    }
    paint_rectangle $x $bulk_y $bulk_width $bulk_height $substrate_layer

    # Draw bulk contacts
    set num_bulk_contacts [floor_value [expr ($bulk_width - 2*$contact_tap_enclosure + $contact_spacing) / ($contact_size + $contact_spacing)]]
    set bulk_contact_offset [expr ($bulk_width - $contact_size*$num_bulk_contacts - $contact_spacing*($num_bulk_contacts-1)) / 2.0]
    set bulk_contact_x [expr $x + $bulk_contact_offset]
    set bulk_contact_y [expr $bulk_y + $contact_tap_enclosure]
    for {set i 0} {$i < $num_bulk_contacts} {incr i} {
        paint_rectangle $bulk_contact_x $bulk_contact_y $contact_size $contact_size $substrate_contact_layer
        set bulk_contact_x [expr $bulk_contact_x + $contact_size + $contact_spacing]
    }

    # Draw local interconnect for source/bulk connection
    if {$device_type == "nmos"} {
        set bulk_source_height [expr $y + $width - $contact_offset - $contact_size - $bulk_contact_y]
    } else {
        set bulk_source_height [expr $bulk_contact_y - ($y + $contact_offset)]
    }
    
    # Vertical LI strip connecting source to bulk
    set li_x1 [expr $source_x - $li_contact_extension]
    if {$device_type == "nmos"} {
        #set li_y1 [expr $source_y - $li_contact_extension - $bulk_source_height]
        set li_y1 [expr $bulk_contact_y]
    } else {
        set li_y1 [expr $y + $contact_offset - $li_contact_extension]
    }
    set li_height [expr $bulk_source_height + $contact_with_li_width]
    paint_rectangle $li_x1 $li_y1 $contact_with_li_width $li_height "li"
    
    # Horizontal LI strip along bulk
    paint_rectangle $x [expr $bulk_contact_y - $li_contact_extension] $diffusion_width $contact_with_li_width "li"

    # Draw N-well for PMOS
    if {$device_type == "pmos"} {
        set well_width [expr $diffusion_width + 2*$diffusion_to_nwell_enclosure]
        set well_height [expr $width + 2*$diffusion_to_nwell_enclosure + $min_diffusion_spacing + $bulk_height]
        paint_rectangle [expr $x - $diffusion_to_nwell_enclosure] \
                       [expr $y - $diffusion_to_nwell_enclosure] \
                       $well_width $well_height "nwell"
    }

    # Return coordinates for connections
    if {$device_type == "nmos"} {
        return [list $gate_x [expr $gate_y+$gate_height] $drain_x [expr $y+$contact_offset] $bulk_contact_y]
    } else {
        return [list $gate_x $gate_y $drain_x [expr $y+$width-$contact_offset-$contact_size] $bulk_contact_y]
    }
}

#===============================================================================
# INVERTER GENERATION
#===============================================================================

# Draw an inverter
# Parameters:
#   x, y: Bottom-left corner of PMOS diffusion
#   pmos_width, pmos_length: PMOS dimensions
#   nmos_width, nmos_length: NMOS dimensions
# Returns: List of key coordinates [gate_x gate_y output_x output_y vdd_y vss_y]
proc draw_inverter {x y pmos_width pmos_length nmos_width nmos_length} {
    global contact_diffusion_enclosure contact_size contact_to_poly_spacing
    global li_contact_extension contact_with_li_width
    global diffusion_to_nwell_enclosure nwell_to_diffusion_spacing
    global min_poly_width
    set poly_width $min_poly_width

    # Calculate NMOS diffusion dimensions
    set nmos_side_width [expr $contact_diffusion_enclosure + $contact_size + $contact_to_poly_spacing]
    set nmos_diffusion_width [expr $nmos_length + 2*$nmos_side_width]
    
    # Calculate NMOS Y position (below PMOS with proper spacing)
    set nmos_y [expr $y - $diffusion_to_nwell_enclosure - $nwell_to_diffusion_spacing - $nmos_diffusion_width]
    
    # Draw PMOS and NMOS transistors
    lassign [draw_single_transistor $x $y $pmos_width $pmos_length "pmos"] p_gate_x p_gate_y p_drain_x p_drain_y vdd_y
    lassign [draw_single_transistor $x $nmos_y $nmos_width $nmos_length "nmos"] n_gate_x n_gate_y n_drain_x n_drain_y vss_y
    
    # Connect gates with poly (vertical stripe)
    paint_rectangle $n_gate_x $n_gate_y $poly_width [expr $p_gate_y - $n_gate_y] "poly"
    
    # Connect drains with LI (vertical stripe connecting NMOS and PMOS drains)
    paint_rectangle [expr $n_drain_x - $li_contact_extension] \
                   [expr $n_drain_y - $li_contact_extension] \
                   $contact_with_li_width \
                   [expr $p_drain_y - $n_drain_y + $contact_with_li_width] "li"
    
    return [list $n_gate_x $n_gate_y $n_drain_x $n_drain_y $vdd_y $vss_y]
}

#===============================================================================
# BUFFER GENERATION (Two inverters in series)
#===============================================================================

# Draw a buffer cell (two inverters in series)
# Parameters:
#   x, y: Bottom-left corner of first inverter PMOS
# Returns: None (draws complete buffer with labels)
proc draw_buffer {x y} {
    global li_contact_extension contact_size
    global contact_with_poly_width contact_poly_enclosure
    global contact_with_li_width nwell_spacing diffusion_to_nwell_enclosure
    global contact_diffusion_enclosure
    global min_poly_width
    set poly_width $min_poly_width

    # First inverter (smaller) - drives input
    # PMOS: W=1.0um, L=0.15um, NMOS: W=0.42um, L=0.15um
    lassign [draw_inverter $x $y 1.0 0.15 0.42 0.15] \
            inv1_gate_x inv1_gate_y inv1_out_x inv1_out_y inv1_vdd_y inv1_vss_y
    
    # Calculate position for second inverter (larger)
    # N-well edge from first inverter
    set nwell_x [expr $inv1_out_x + $contact_size + $contact_diffusion_enclosure + $diffusion_to_nwell_enclosure]
    
    # Second inverter (larger) - drives output
    # PMOS: W=2.0um, L=0.15um, NMOS: W=0.84um, L=0.15um
    lassign [draw_inverter [expr $nwell_x + $nwell_spacing + $diffusion_to_nwell_enclosure] $y \
            2.0 0.15 0.84 0.15] \
            inv2_gate_x inv2_gate_y inv2_out_x inv2_out_y inv2_vdd_y inv2_vss_y

    #===========================================================================
    # Connect first inverter output to second inverter input
    #===========================================================================
    
    # Calculate connection point between inverters
    set connection_point_x [expr $inv1_out_x + ($inv2_gate_x - $inv1_out_x) * 0.5]
    set vertical_offset 1.0  ;# Vertical offset for routing
    
    # Draw horizontal LI strip from first inverter output
    set metal_x [expr $inv1_out_x - $li_contact_extension]
    set metal_y [expr $inv1_out_y - $li_contact_extension + $vertical_offset]
    set metal_width [expr 2*$li_contact_extension + $contact_size]
    set metal_distance [expr $connection_point_x - $inv1_out_x + $metal_width]
    paint_rectangle $metal_x $metal_y $metal_distance $metal_width "li"
    
    # Second inverter gate connection point (slightly above gate)
    set inv2_gate_connect_y [expr $inv2_gate_y + 0.15]
    
    # Draw contact to connect LI to poly
    set contact_x [expr $metal_x + $metal_distance - $li_contact_extension - $contact_size]
    set contact_y $inv2_gate_connect_y
    paint_rectangle $contact_x $contact_y $contact_size $contact_size "polyc"

    set contact_cx [expr $contact_x+$contact_size/2]
    set contact_cy [expr $contact_y+$contact_size/2]

    draw_label_with_box $contact_cx $contact_cy "net1"
    
    # Draw poly enclosure around contact
    paint_rectangle [expr $contact_x - $contact_poly_enclosure] \
                   [expr $contact_y - $contact_poly_enclosure] \
                   $contact_with_poly_width $contact_with_poly_width "poly"
    
    # Connect contact to second inverter gate with poly
    paint_rectangle $connection_point_x $inv2_gate_connect_y \
                   [expr $inv2_gate_x - $connection_point_x + $poly_width] $poly_width "poly"

    #===========================================================================
    # Draw power rails (VDD and VSS)
    #===========================================================================
    
    # VDD rail (top)
    set vdd_x [expr $nwell_x - $diffusion_to_nwell_enclosure]
    set vdd_y [expr $inv1_vdd_y - $li_contact_extension]
    set vdd_width [expr $nwell_spacing + 2*$diffusion_to_nwell_enclosure + 2*$li_contact_extension]
    paint_rectangle $vdd_x $vdd_y $vdd_width $metal_width "li"
    
    # VSS rail (bottom)
    set vss_x $vdd_x
    set vss_y [expr $inv1_vss_y - $li_contact_extension]
    paint_rectangle $vss_x $vss_y $vdd_width $metal_width "li"

    #===========================================================================
    # Draw input connection (A)
    #===========================================================================
    
    # Input contact position
    set input_contact_x [expr $inv1_gate_x + $poly_width - $contact_size/2 - $contact_poly_enclosure-0.15]
    set input_contact_y [expr $inv1_gate_y + 0.25]
    
    # Input contact
    set input_contact_x_adj [expr $input_contact_x - $contact_size/2]
    set input_contact_y_adj [expr $input_contact_y - $contact_size/2]
    paint_rectangle $input_contact_x_adj $input_contact_y_adj $contact_size $contact_size "polyc"
    
    # Poly enclosure around input contact
    paint_rectangle [expr $input_contact_x_adj - $contact_poly_enclosure] \
                   [expr $input_contact_y_adj - $contact_poly_enclosure] \
                   $contact_with_poly_width $contact_with_poly_width "poly"
    
    # LI pad for input
    paint_rectangle [expr $input_contact_x_adj - $li_contact_extension] \
                   [expr $input_contact_y_adj - $li_contact_extension] \
                   $contact_with_li_width $contact_with_li_width "li"
    
    #===========================================================================
    # Draw output connection (Y)
    #===========================================================================
    
    # Output contact position (centered on second inverter drain)
    set output_contact_x [expr $inv2_out_x + $contact_size/2]
    set output_contact_y [expr $inv2_out_y + $contact_size/2]

    #===========================================================================
    # Add labels
    #===========================================================================
    
    draw_label_with_box $input_contact_x $input_contact_y "A"
    port make 1
    draw_label_with_box $output_contact_x $output_contact_y "Y"
    port make 2
    draw_label_with_box $vdd_x [expr $vdd_y + $li_contact_extension + $contact_size/2] "VDD"
    port make 3
    draw_label_with_box $vss_x [expr $vss_y + $li_contact_extension + $contact_size/2] "VSS"
    port make 4
}

#===============================================================================
# MAIN EXECUTION
#===============================================================================

# Load technology and setup
tech load sky130A
drc off
snap internal
grid 0.005um 0.005um

# Load existing layout if any (optional)
catch {load buf -force}

# Draw buffer cell at origin
draw_buffer 0 0

# Save layout
save

# Exit
quit
