# !/bin/bash
# 使用  ./autoInsertDylib.sh  ipa文件路径  dylib文件路径  eg: ./autoInsertDylib.sh wechat.ipa robot.dylib

shell_path="$(dirname "$0")"

SOURCEIPA="$1"
DYLIB="$2"
LIBSUBSTRATE="${shell_path}/libsubstrate.dylib"

temp_dir="${shell_path}/tweak-temp-tk"
ipa_bundle_path="${temp_dir}/${SOURCEIPA##*/}"
libsubstrate_path="${temp_dir}/${LIBSUBSTRATE##*/}"
dylib_path="${temp_dir}/${DYLIB##*/}"

framework_path="${app_bundle_path}/${framework_name}.framework"
rm -rf ${shell_path}/../Products/*
mkdir ${shell_path}/../Products/
if [ ! -d ${temp_dir} ]; then
	# echo "创建 ${temp_dir}"
	mkdir ${temp_dir}
fi

cp "$SOURCEIPA" "$DYLIB" "$LIBSUBSTRATE" ${temp_dir}

# cd "$shell_path"

echo "开始注入dylib >>> \n\n\n"
# echo "正将" ${SOURCEIPA##*/} ${DYLIB##*/} ${LIBSUBSTRATE##*/}  "拷贝至/tweak-temp-tk"

otool -L ${dylib_path} > ${temp_dir}/depend.log
grep "/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate" ${temp_dir}/depend.log >${temp_dir}/grep_result.log
if [ $? -eq 0 ]; then
    # echo "发现有 ${DYLIB##*/} 依赖于 CydiaSubstrate, 正将其替换为 libsubstrate"
	install_name_tool -change /Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate @loader_path/libsubstrate.dylib ${dylib_path}

# else
    # echo "没有发现依赖于CydiaSubstrate"
fi

# echo "解压" ${SOURCEIPA##*/}

unzip -qo "$ipa_bundle_path" -d ${shell_path}/extracted

APPLICATION=$(ls "${shell_path}/extracted/Payload/")
app_path="${shell_path}/extracted/Payload/${APPLICATION}"

# cp -R ${app_path} ./

# rm -rf ~/Desktop/temp/extracted/Payload/$APPLICATION/*Watch*
cp "${shell_path}/popup_close_btn.png" ${app_path}
cp ${dylib_path} ${libsubstrate_path} ${app_path}

# echo "删除" ${APPLICATION##*/} "中 watch 相关文件"

rm -rf ${app_path}/*watch* ${app_path}/*Watch*

# echo "注入" ${DYLIB##*/} "到" $APPLICATION
${shell_path}/insert_dylib  @executable_path/${DYLIB##*/} ${app_path}/${APPLICATION%.*} > ${temp_dir}/insert_dylib.log

echo "注入成功 !!!"

rm -rf ${app_path}/${APPLICATION%.*}
mv ${app_path}/${APPLICATION%.*}_patched ${app_path}/${APPLICATION%.*}

cp -R ${app_path} ${shell_path}/../Products/${APPLICATION}

# echo "删除临时文件 >>>"
rm -rf ${shell_path}/extracted ${temp_dir}

# echo "打开 tweak-temp-tk 文件夹"
open ${shell_path}/../Products/
# open /Applications/iOS\ App\ Signer.app
