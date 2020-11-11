# ICONTool

批量生成各尺寸ICON工具，支持高度自定义，支持导出分文件夹、自定义图片命名已经指定圆角等


# 详细说明如下：

1、格式说明txt的文件名即为导出icon的文件夹，根据业务需要自定义txt文件并自行命名即可
2、尺寸格式为：宽x高，多个尺寸用换行符隔开即可，如：
  120x120
  180x180
  1024x1024
3、默认图片以尺寸命名，如果需要自定义命名图片，只需在对应尺寸前添加图片名，并用冒号:隔开，如：
  1024:1024x1024
4、如果某个txt文件需要导出多个子文件夹，只需在某一组的第一行添加子文件名并用#号隔开，如：
  iOS#
  120x120
  180x180
  1024x1024

  Android#
  90x90
  512x512
  1024x1024

5、如需导出带圆角的图片，只需在某一组的前面添加R=圆角值即可，该圆角值针对原图，其他生成图将按比例自行缩放圆角，如果该组有子文件夹，则需要放在文件夹后面，如：
  iOS#
  R=230
  120x120
  180x180
  1024x1024
6、子文件夹名和图片名称均支持中文
