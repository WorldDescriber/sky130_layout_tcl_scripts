#===============================================================================
# Magic Layout Script for CMOS Inverter (SkyWater 130nm Process)
#===============================================================================
# This script generates a complete CMOS inverter layout with:
# - PMOS and NMOS transistors with configurable W/L ratios
# - Proper substrate contacts (N-tap for PMOS, P-tap for NMOS)
# - Local interconnect (LI) routing for power (VDD/VSS) and output (Y)
# - Poly connection for input (A)
#===============================================================================

#===============================================================================
# UTILITY FUNCTIONS
#===============================================================================

# Integer floor function for layout calculations
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

#===============================================================================
# TECHNOLOGY SETUP
#===============================================================================

# Load technology and configure environment
tech load sky130A
drc off               
# Disable DRC for faster generation
snap internal         
# Enable grid snapping
grid 0.005um 0.005um  
# Set grid to 0.005um (1 lambda in typical lambda-based design)

#===============================================================================
# DESIGN RULES (SkyWater 130nm)
#===============================================================================
# Based on SkyWater PDK design rules (rev 2023-09-14)

# Basic units
set lambda 0.005      
# 5nm grid unit

# Diffusion (Active Area) Rules
set min_diff_width     0.15   
# Minimum diffusion width (diff.1)
set diffusion_spacing  0.27   
# Minimum diffusion spacing (diff.3)

# Poly Rules
set min_poly_width     0.15   
# Minimum poly width (poly.1)
set poly_extension     0.15   
# Poly extension beyond diffusion (poly.3)
set poly_to_contact_spacing 0.15 
# Poly to diffusion contact spacing (poly.6)

# Contact Rules (LICON - Local Interconnect Contact)
set contact_size       0.17   
# LICON size (licon.1)
set contact_spacing    0.17   
# LICON to LICON spacing (licon.2)
set li_to_li_spacing   0.17   
# LI to LI spacing (li.3)

# Enclosure Rules
set contact_diffusion_enclosure 0.15 
# LICON enclosure by diffusion (licon.3)
set contact_poly_enclosure      0.10 
# LICON enclosure by poly (licon.4)
set contact_li_extension        0.08 
# LI extension beyond LICON (li.4)

# Well Rules
set diffusion_nwell_enclosure   0.18 
# Diffusion enclosure by N-well (diff.10)
set ndiff_to_nwell_spacing      0.34 
# N-diff to N-well spacing (diff.9)

# Derived dimensions
set li_contact_width [expr $contact_size + 2 * $contact_li_extension]
set diffusion_contact_width [expr $contact_size + 2 * $contact_diffusion_enclosure]
set poly_contact_width [expr $contact_size + 2 * $contact_poly_enclosure]

#===============================================================================
# LAYOUT PRIMITIVES
#===============================================================================

# Helper to paint a rectangular box
proc paint_rectangle {x y width height layer} {
    box [expr $x]um [expr $y]um [expr $x+$width]um [expr $y+$height]um
    paint $layer
}

#===============================================================================
# TRANSISTOR GENERATION
#===============================================================================

# Creates a complete transistor structure with source/drain and bulk contacts
# Parameters:
#   x, y - bottom-left corner coordinates
#   channel_width - transistor width (W)
#   channel_length - transistor length (L)
#   device_type - "nmos" or "pmos"
#
# Returns: List [gate_x gate_y drain_contact_x drain_contact_y]
proc create_transistor {x y channel_width channel_length device_type} {
   
# Import global design rules
    global li_to_li_spacing
    global contact_diffusion_enclosure
    global contact_size
    global poly_to_contact_spacing
    global contact_li_extension
    global li_contact_width
    global min_poly_width
    global poly_extension
    global contact_poly_enclosure
    global poly_contact_width
    global diffusion_contact_width
    global diffusion_spacing
    global diffusion_nwell_enclosure
    global contact_spacing

   
# Set layer names based on device type
    if {$device_type == "nmos"} {
        set diffusion_layer "ndiff"
        set diffusion_contact_layer "ndiffc"
        set substrate_diffusion_layer "psubdiff"
        set substrate_contact_layer "psubdiffc"
        set bulk_label "VSS"
    } else {
        set diffusion_layer "pdiff"
        set diffusion_contact_layer "pdiffc"
        set substrate_diffusion_layer "nsubdiff"
        set substrate_contact_layer "nsubdiffc"
        set bulk_label "VDD"
    }

   
#---------------------------------------------------------------------------
   
# Calculate dimensions
   
#---------------------------------------------------------------------------
    
   
# Diffusion region dimensions
    set diffusion_side_length [expr $contact_diffusion_enclosure + $contact_size + $poly_to_contact_spacing]
    set diffusion_width [expr $channel_length + 2 * $diffusion_side_length]
    set diffusion_height [expr $channel_width]
    
   
# Poly gate dimensions
    set poly_needed_height [expr 2 * $poly_extension + $diffusion_height]
    
   
# Calculate number of contacts along diffusion height
    set available_contact_height [expr $diffusion_height - 2 * $contact_diffusion_enclosure]
    set contact_pitch [expr $contact_size + $contact_spacing]
    set contact_count [floor_value [expr ($available_contact_height + $contact_spacing) / $contact_pitch]]
    
   
# Calculate Y-offset for contacts (centered)
    set total_contacts_height [expr $contact_count * $contact_size + ($contact_count - 1) * $contact_spacing]
    set contact_y_offset [expr ($diffusion_height - $total_contacts_height) / 2.0]

   
#---------------------------------------------------------------------------
   
# Draw transistor structure
   
#---------------------------------------------------------------------------
    
   
# Diffusion region (source/drain)
    set diffusion_x $x
    set diffusion_y $y
    paint_rectangle $diffusion_x $diffusion_y $diffusion_width $diffusion_height $diffusion_layer

   
# Poly gate
    set gate_x [expr $x + $diffusion_side_length]
    set gate_y [expr $y - $poly_extension]
    set gate_width $min_poly_width
    set gate_height $poly_needed_height
    paint_rectangle $gate_x $gate_y $gate_width $gate_height "poly"

   
# Source contacts
    set source_contact_x [expr $x + $contact_diffusion_enclosure]
    set source_contact_y [expr $y + $contact_y_offset]
    
    for {set i 0} {$i < $contact_count} {incr i} {
        set current_y [expr $source_contact_y + $i * ($contact_size + $contact_spacing)]
        paint_rectangle $source_contact_x $current_y $contact_size $contact_size $diffusion_contact_layer
    }

   
# Drain contacts
    set drain_contact_x [expr $x + $diffusion_width - $contact_diffusion_enclosure - $contact_size]
    set drain_contact_y $source_contact_y
    
    for {set i 0} {$i < $contact_count} {incr i} {
        set current_y [expr $drain_contact_y + $i * ($contact_size + $contact_spacing)]
        paint_rectangle $drain_contact_x $current_y $contact_size $contact_size $diffusion_contact_layer
    }

   
#---------------------------------------------------------------------------
   
# Bulk (substrate) contact
   
#---------------------------------------------------------------------------
    
    set bulk_diffusion_width $diffusion_contact_width
    set bulk_diffusion_x $x
    
    if {$device_type == "nmos"} {
       
# Place P-tap below NMOS
        set bulk_diffusion_y [expr $y - $diffusion_spacing - $bulk_diffusion_width]
    } else {
       
# Place N-tap above PMOS
        set bulk_diffusion_y [expr $y + $diffusion_height + $diffusion_spacing]
    }
    
    paint_rectangle $bulk_diffusion_x $bulk_diffusion_y $bulk_diffusion_width $bulk_diffusion_width $substrate_diffusion_layer
    
   
# Bulk contact
    set bulk_contact_x [expr $bulk_diffusion_x + $contact_diffusion_enclosure]
    set bulk_contact_y [expr $bulk_diffusion_y + $contact_diffusion_enclosure]
    paint_rectangle $bulk_contact_x $bulk_contact_y $contact_size $contact_size $substrate_contact_layer

   
#---------------------------------------------------------------------------
   
# Local interconnect (LI) for source/bulk connection
   
#---------------------------------------------------------------------------
    
    set li_width $li_contact_width
    
   
# Calculate source-to-bulk distance for LI routing
    if {$device_type == "nmos"} {
       
# Connect source (top) to bulk (bottom)
        set source_top_y [expr $y + $diffusion_height - $contact_y_offset - $contact_size]
        #set source_top_y [expr $y + $diffusion_height - $contact_y_offset ]
        #set bulk_bottom_y [expr $bulk_contact_y + $contact_size]
        set bulk_bottom_y [expr $bulk_contact_y ]
        set vertical_distance [expr $source_top_y - $bulk_bottom_y]
    } else {
       
# Connect source (bottom) to bulk (top)
        set source_bottom_y [expr $y + $contact_y_offset]
        set bulk_top_y $bulk_contact_y
        set vertical_distance [expr $bulk_top_y - $source_bottom_y]
    }

   
# Vertical LI stripe from source
    set li_source_x [expr $source_contact_x - $contact_li_extension]
    if {$device_type == "nmos"} {
        #set li_source_y [expr $source_contact_y - $contact_li_extension - $vertical_distance]
        set li_source_y [expr $bulk_contact_y - $contact_li_extension ]
    } else {
        set li_source_y [expr $y + $contact_y_offset - $contact_li_extension]
    }
    set li_source_height [expr $vertical_distance + $li_contact_width]
    paint_rectangle $li_source_x $li_source_y $li_width $li_source_height "li"
    
   
# Horizontal LI stripe from bulk
    set li_bulk_x [expr $bulk_contact_x - $contact_li_extension]
    set li_bulk_y [expr $bulk_contact_y - $contact_li_extension]
    paint_rectangle $li_bulk_x $li_bulk_y $li_source_height $li_width "li"
    
   
# Label bulk connection
    label $bulk_label FreeSans 60
    if {$device_type == "nmos"} {
        port make 4
    } else {
        port make 3
    }


   
#---------------------------------------------------------------------------
   
# N-well for PMOS
   
#---------------------------------------------------------------------------
    
    if {$device_type == "pmos"} {
        set well_width [expr $diffusion_width + 2 * $diffusion_nwell_enclosure]
        set well_height [expr $diffusion_height + 2 * $diffusion_nwell_enclosure + $diffusion_spacing + $bulk_diffusion_width]
        set well_x [expr $diffusion_x - $diffusion_nwell_enclosure]
        set well_y [expr $diffusion_y - $diffusion_nwell_enclosure]
        paint_rectangle $well_x $well_y $well_width $well_height "nwell"
    }

   
# Return coordinates for later connections
    if {$device_type == "nmos"} {
        return [list $gate_x [expr $gate_y + $gate_height] $drain_contact_x [expr $y + $contact_y_offset]]
    } else {
        return [list $gate_x $gate_y $drain_contact_x $drain_contact_y]
    }
}

#===============================================================================
# INVERTER INTEGRATION
#===============================================================================

# Creates a complete CMOS inverter by placing PMOS and NMOS transistors
# and connecting them appropriately
#
# Parameters:
#   x, y - reference point for inverter placement
proc create_inverter {x y} {
    global contact_diffusion_enclosure
    global contact_size
    global poly_to_contact_spacing
    global contact_li_extension
    global min_poly_width
    global li_contact_width
    global diffusion_nwell_enclosure
    global ndiff_to_nwell_spacing

   
#---------------------------------------------------------------------------
   
# PMOS transistor (pull-up network)
   
#---------------------------------------------------------------------------
    set pmos_width 2.0     
# PMOS wider for balanced drive strength
    set pmos_length 0.15   
# Minimum length
    lassign [create_transistor $x $y $pmos_width $pmos_length "pmos"] \
           pmos_gate_x pmos_gate_y pmos_drain_x pmos_drain_y

   
#---------------------------------------------------------------------------
   
# NMOS transistor (pull-down network)
   
#---------------------------------------------------------------------------
    set nmos_width 1.0     
# NMOS narrower (higher mobility)
    set nmos_length 0.15   
# Minimum length
    
   
# Calculate NMOS placement (below PMOS with proper spacing)
    set nmos_diffusion_side [expr $contact_diffusion_enclosure + $contact_size + $poly_to_contact_spacing]
    set nmos_diffusion_height [expr $nmos_length + 2 * $nmos_diffusion_side]
    
    set nmos_y [expr $y - $diffusion_nwell_enclosure - $ndiff_to_nwell_spacing - $nmos_diffusion_height]
    lassign [create_transistor $x $nmos_y $nmos_width $nmos_length "nmos"] \
           nmos_gate_x nmos_gate_y nmos_drain_x nmos_drain_y

   
#---------------------------------------------------------------------------
   
# Gate connection (input A)
   
#---------------------------------------------------------------------------
   
# Vertical poly stripe connecting PMOS and NMOS gates
    paint_rectangle $nmos_gate_x $nmos_gate_y $min_poly_width [expr $pmos_gate_y - $nmos_gate_y] "poly"
    label A FreeSans 60
    port make 1

   
#---------------------------------------------------------------------------
   
# Drain connection (output Y)
   
#---------------------------------------------------------------------------
   
# Local interconnect connecting PMOS and NMOS drains
    set drain_li_x [expr $nmos_drain_x - $contact_li_extension]
    set drain_li_y [expr $nmos_drain_y - $contact_li_extension]
    #set drain_li_height [expr $pmos_drain_y - $nmos_drain_y + $li_contact_width]
    set drain_li_height [expr $y+$pmos_width - ($pmos_drain_y-$y) - $nmos_drain_y + $contact_li_extension*2]
    paint_rectangle $drain_li_x $drain_li_y $li_contact_width $drain_li_height "li"
    label Y FreeSans 60
    port make 2
}

#===============================================================================
# MAIN EXECUTION
#===============================================================================

# Load or create the layout cell
load cmos_inverter -force

# Generate the inverter at origin
create_inverter 0 0

# Save the layout
save

# Exit Magic
quit
