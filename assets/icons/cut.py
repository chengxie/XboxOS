##
# @file     cut.py
# @brief    
# @author   My name is CHENG XIE. I am your God! wa hahaha...
# @version  1.0
# @date     2024-12-03

from PIL import Image
import os

def crop_images(input_dir, output_dir):
    """
    裁剪所有660x177的PNG图片，保留右边500x177部分。

    :param input_dir: 输入图片目录
    :param output_dir: 输出图片目录
    """
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # 遍历输入目录中的所有文件
    for file_name in os.listdir(input_dir):
        if file_name.lower().endswith(".png"):
            input_path = os.path.join(input_dir, file_name)
            output_path = os.path.join(output_dir, file_name)
            
            try:
                # 打开图片
                img = Image.open(input_path)
                width, height = img.size
                
                # 检查图片尺寸是否为660x177
                if width == 660 and height == 177:
                    # 裁剪左边160像素，保留右边500x177
                    cropped_img = img.crop((160, 0, 660, 177))
                    cropped_img.save(output_path)
                    print(f"裁剪并保存: {output_path}")
                else:
                    print(f"跳过（尺寸不匹配）: {input_path}")
            except Exception as e:
                print(f"处理文件时出错: {input_path} - {e}")

# 输入和输出目录
input_directory = "."  # 替换为您的输入目录路径
output_directory = "."  # 替换为您的输出目录路径

# 执行裁剪
crop_images(input_directory, output_directory)

