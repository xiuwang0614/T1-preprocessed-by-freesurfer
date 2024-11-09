#!/bin/bash
# FreeSurfer 安装目录
export FREESURFER_HOME="/opt/fox_cloud/share/app/imaging/freesurfer7.3"  # 将此路径替换为实际安装路径
source $FREESURFER_HOME/SetUpFreeSurfer.sh
export FS_LOAD_DWI=0
# 设置包含多个子文件夹的主目录
main_dir="/home/wangrong/0BDrawdata"

# 定义保存所有 DICOM 文件路径的文件
output_file="all_first_dicom_files.txt"

# 清空或新建输出文件
> "$output_file"

# 遍历主目录下的每个子文件夹
for sub_dir in "$main_dir"/*/; do
    # 检查是否是目录
    if [ -d "$sub_dir" ]; then
        echo "Processing directory: $sub_dir"  # 调试信息

        # 在当前子文件夹中查找第一个 DICOM 文件
        find "$sub_dir" -type f | while read -r file; do
            # 使用 file 命令判断文件类型
            file_type=$(file --mime-type -b "$file")
            if [[ "$file_type" == "application/dicom" ]]; then
                # 将包含第一个 DICOM 文件的文件夹路径追加写入到 output_file 中并退出循环
                echo "$sub_dir" >> "$output_file"
                echo "First DICOM folder saved to $output_file: $sub_dir"
                break
            fi
        done
        
    fi
done


