#################################################################
## File:            watercount.tcl
## Description:     Computes TM3 and TM6/TM7 Water Counts
## Author:          Sohom Dash
## Last Modified:   2026-04-27
#################################################################

# Require json package to load system info
package require json

# Get system from command line argument
set system [lindex $argv 0]

# Make output directory
file mkdir data/waters/${system}

# Path assumes that config.json is located in src/ and the vmd job submit script is run from the analysis directory (e.g. beta1_analysis/)
set json_fp [open "src/config.json" r]
set json_str [read $json_fp]
set system_configs [::json::json2dict $json_str]
close $json_fp

# Set psf file and trajectory file type
set psf_fp [dict get $system_configs $system psf]
set traj_type [dict get $system_configs $system trajectory_format]

# Function adapted from scripts by George Khelashvili
proc calculate {trajfile out} {
    global psf_fp
    global traj_type

    # Add new molecule
    mol new $psf_fp
    mol addfile ${trajfile}.${traj_type} type $traj_type waitfor all

    # Get number of frames
    set nf [molinfo top get numframes]

    # Open output file and write header
    set outfile [open $out w]
    puts $outfile "frame\tWater_TM3_Full\tWater_TM3_EC\tWater_TM6_TM7_Full"

    # Loop through frames in trajectory and compute water counts
    for {set f 0} {$f<$nf} {incr f} {

        ## Full TM3 Water Counts ##
        set watersel_TM3_Full [atomselect top "(water and same residue as within 5 of (protein and segid PROA and resid 123 130 133 134 136 137 161 164 168 172 210 211 214 222 and sidechain)) and noh" frame $f]
        set watercounts_TM3_Full [$watersel_TM3_Full num]
        
        ## EC TM3 Water Counts ##
        set watersel_TM3_EC [atomselect top "(water and same residue as within 5 of (protein and segid PROA and resid 123 172 173 210 211 and sidechain)) and noh" frame $f]
        set watercounts_TM3_EC [$watersel_TM3_EC num]

        ## Full TM6/TM7 Water Counts ##
        set watersel_TM6_TM7_Full [atomselect top "(water and same residue as within 5 of (protein and segid PROA and resid 84 121 128 295 300 305 331 304 332 335 337 338 339 and sidechain)) and noh" frame $f]
        set watercounts_TM6_TM7_Full [$watersel_TM6_TM7_Full num]

        # Output counts to file
        puts $outfile "$f\t$watercounts_TM3_Full\t$watercounts_TM3_EC\t$watercounts_TM6_TM7_Full"
    }

    # Close output file and delete molecule
    close $outfile
    mol delete top
}

# Get trajectory info
set traj_path [dict get $system_configs $system wrapped_trajectories]
set num_traj [dict get $system_configs $system num_trajectories]

# Loop through trajectories and run calculate function
for {set t 0} {$t < $num_traj} {incr t} {
    set t_padded [format "%04d" $t]
    calculate ${traj_path}/trajectory_${t_padded} data/waters/${system}/watercounts_${system}_${t_padded}.txt
}
