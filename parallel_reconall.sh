#!/bin/bash

# FreeSurfer 安装目录
export FREESURFER_HOME="/opt/fox_cloud/share/app/imaging/freesurfer7.3"
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

# 生成并行处理任务的命令
generate_task() {
    sub_dir="$1"
    subject_id=$(basename "$sub_dir")
    output_subject_dir="$output_base_dir/$subject_id"

    # 在当前子文件夹中查找第一个 DICOM 文件
    find "$sub_dir" -type f | while read -r file; do
        file_type=$(file --mime-type -b "$file")
        if [[ "$file_type" == "application/dicom" ]]; then
            # 执行 dcmunpack 命令，生成 scan.log 文件
            dcmunpack -src "$sub_dir" -scanonly "$sub_dir/scan.log"

            # 从 scan.log 中提取 T1-weighted 序列的 DICOM 文件
            t1_dicom=$(grep -i "t1" "$sub_dir/scan.log" | awk '{print $NF}' | head -n 1)

            if [ -n "$t1_dicom" ]; then
                # 执行 recon-all 命令，处理每个被试的 T1 DICOM 文件
                mkdir -p "$output_subject_dir"
                prctl --set-name "FS_recon_all_process_$subject_id"
                recon-all -i "$t1_dicom" -s "$subject_id" -all -sd "$output_subject_dir"
            fi
        fi
    done
}

export -f generate_task  # 导出函数

# 使用 parallel 并行执行任务，并限制最大并行数为 6
find "$main_dir" -mindepth 1 -maxdepth 1 -type d | parallel -j 6 generate_task

