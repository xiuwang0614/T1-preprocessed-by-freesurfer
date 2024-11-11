#!/bin/bash

# FreeSurfer installation directory
export FREESURFER_HOME="/opt/fox_cloud/share/app/imaging/freesurfer7.3"  # Replace with actual path
source $FREESURFER_HOME/SetUpFreeSurfer.sh
export FS_LOAD_DWI=0

# Main directory and output file paths
main_dir="/home/wangrong/0BDrawdata"
output_folder_file="all_first_dicom_folders.txt"  
output_t1_file="t1_dicom_files.txt"
output_base_dir="/home/wangrong/Desktop/BD"  # Directory to store FreeSurfer outputs

# Clear or create output files
> "$output_folder_file"
> "$output_t1_file"

# Process each sub-directory to find DICOMs and extract T1-weighted files
for sub_dir in "$main_dir"/*/; do
    # Check if it's a directory
    if [ -d "$sub_dir" ]; then
        echo "Processing directory: $sub_dir"

        # Find the first DICOM file in the current sub-folder
        find "$sub_dir" -type f | while read -r file; do
            file_type=$(file --mime-type -b "$file")
            if [[ "$file_type" == "application/dicom" ]]; then
                # Save the first DICOM folder path
                echo "$sub_dir" >> "$output_folder_file"
                echo "First DICOM folder saved to $output_folder_file: $sub_dir"

                # Run dcmunpack to create scan.log
                dcmunpack -src "$sub_dir" -scanonly "$sub_dir/scan.log"

                # Extract T1-weighted DICOM file from scan.log
                t1_dicom=$(grep -i "t1" "$sub_dir/scan.log" | awk '{print $NF}' | head -n 1)

                # Check if T1 DICOM was found
                if [ -n "$t1_dicom" ]; then
                    echo "$t1_dicom" >> "$output_t1_file"
                    echo "T1-weighted DICOM file for subject in $sub_dir saved to $output_t1_file: $t1_dicom"

                    # Define subject ID and output directory for recon-all
                    subject_id=$(basename "$sub_dir")
                    output_subject_dir="$output_base_dir/$subject_id"
                    mkdir -p "$output_subject_dir"

                    # Use GNU Parallel to run recon-all in parallel
                    echo "recon-all -i \"$t1_dicom\" -s \"$subject_id\" -all -sd \"$output_subject_dir\"" >> commands.txt
                else
                    echo "No T1-weighted DICOM found for subject in $sub_dir"
                fi
                break
            fi
        done
    fi
done

# Run recon-all commands in parallel
cat commands.txt | parallel --jobs 6  # Adjust the number of jobs as needed
rm commands.txt

