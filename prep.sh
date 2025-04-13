name=$(basename build/web/*.html .html)

rm build/${name}.zip
zip build/${name}.zip build/web/* -j