#!/bin/bash

# FreeSurfer 安装目录
export FREESURFER_HOME="/opt/fox_cloud/share/app/imaging/freesurfer7.3"  # 将此路径替换为实际安装路径
source $FREESURFER_HOME/SetUpFreeSurfer.sh
export FS_LOAD_DWI=0

# 主目录和输出文件路径
main_dir="/home/wangrong/0BDrawdata"
output_folder_file="all_first_dicom_folders.txt"
output_t1_file="t1_dicom_files.txt"
output_base_dir="/home/wangrong/Desktop/BD"  # 指定存放 FreeSurfer 输出的主目录

# 清空或新建输出文件
> "$output_folder_file"
> "$output_t1_file"

# 遍历主目录下的每个子文件夹
for sub_dir in "$main_dir"/*/; do
    # 检查是否是目录
    if [ -d "$sub_dir" ]; then
        echo "Processing directory: $sub_dir"

        # 在当前子文件夹中查找第一个 DICOM 文件
        find "$sub_dir" -type f | while read -r file; do
            # 使用 file 命令判断文件类型
            file_type=$(file --mime-type -b "$file")
            if [[ "$file_type" == "application/dicom" ]]; then
                # 将包含第一个 DICOM 文件的文件夹路径写入 output_folder_file
                echo "$sub_dir" >> "$output_folder_file"
                echo "First DICOM folder saved to $output_folder_file: $sub_dir"

                # 执行 dcmunpack 命令，生成 scan.log 文件
                dcmunpack -src "$sub_dir" -scanonly "$sub_dir/scan.log"

                # 从 scan.log 中提取 T1-weighted 序列的 DICOM 文件
                t1_dicom=$(grep -i "t1" "$sub_dir/scan.log" | awk '{print $NF}' | head -n 1)

                # 检查是否找到 T1 序列的 DICOM 文件
                if [ -n "$t1_dicom" ]; then
                    # 仅保存 T1 DICOM 文件的路径
                    echo "$t1_dicom" >> "$output_t1_file"
                    echo "T1-weighted DICOM file for subject in $sub_dir saved to $output_t1_file: $t1_dicom"

                    # 创建输出文件夹 (每个被试的文件夹)
                    subject_id=$(basename "$sub_dir")
                    output_subject_dir="$output_base_dir/$subject_id"
                    mkdir -p "$output_subject_dir"
		    #give a name to see in the processes
		    prctl --set-name "freesurfer_recon_all_process_$subject_id"
                    # 执行 recon-all 命令，处理每个被试的 T1 DICOM 文件
                    recon-all -i "$t1_dicom" -s "$subject_id" -all -sd "$output_subject_dir"
                    echo "recon-all completed for subject: $subject_id"

                else
                    echo "No T1-weighted DICOM found for subject in $sub_dir"
                fi
                break  # 找到第一个 DICOM 文件后退出循环
            fi
        done
    fi
done
