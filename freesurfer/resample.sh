#!/bin/bash

# 设置路径
SUBJECTS_DIR=~/Desktop/GAD                   # 被试文件夹的主目录
LH_ANNOT=~/Desktop/lh.500.aparc.annot         # 左半球注释模板文件路径
RH_ANNOT=~/Desktop/rh.500.aparc.annot         # 右半球注释模板文件路径
OUTPUT_DIR=~/Desktop/GAD_results              # 输出结果的存储目录

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

# 遍历每个被试文件夹
for subject in "$SUBJECTS_DIR"/*; do
    if [[ -d "$subject" && $(basename "$subject") != "fsaverage" ]]; then
        # 提取被试名称
        subject_name=$(basename "$subject")
        
        # 确保 label 文件夹存在
        mkdir -p "$subject/label"
        
        # 定义被试左、右半球注释文件的存储路径
        lh_subject_annot="$subject/label/lh.custom.annot"
        rh_subject_annot="$subject/label/rh.custom.annot"
        
        # 使用 mri_surf2surf 将注释文件映射到被试的表面，使用 sphere 注册文件
        mri_surf2surf --srcsubject fsaverage --trgsubject "$subject_name" \
                      --hemi lh --sval-annot "$LH_ANNOT" --tval "$lh_subject_annot" \
                      --srcsurfreg sphere --trgsurfreg sphere

        # 检查左半球文件是否生成
        if [[ ! -f "$lh_subject_annot" ]]; then
            echo "错误：未生成 $lh_subject_annot"
            exit 1
        fi

        mri_surf2surf --srcsubject fsaverage --trgsubject "$subject_name" \
                      --hemi rh --sval-annot "$RH_ANNOT" --tval "$rh_subject_annot" \
                      --srcsurfreg sphere --trgsurfreg sphere

        # 检查右半球文件是否生成
        if [[ ! -f "$rh_subject_annot" ]]; then
            echo "错误：未生成 $rh_subject_annot"
            exit 1
        fi

        # 定义左、右半球结构指标的输出文件路径
        output_lh="$OUTPUT_DIR/${subject_name}_lh_stats.txt"
        output_rh="$OUTPUT_DIR/${subject_name}_rh_stats.txt"
        
        # 使用 .annot 文件提取左、右半球结构指标
        mris_anatomical_stats -a "$lh_subject_annot" -f "$output_lh" -b -cortex "$subject_name" lh
        mris_anatomical_stats -a "$rh_subject_annot" -f "$output_rh" -b -cortex "$subject_name" rh
        
        echo "完成被试 $subject_name 的结构指标提取。"
    fi
done

echo "所有被试的结构指标提取完成，结果存储在 $OUTPUT_DIR 中。"