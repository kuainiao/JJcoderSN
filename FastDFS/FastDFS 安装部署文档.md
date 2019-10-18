# FastDFS 安装部署文档

------



## 安装详细配置文档修改

### Install FastDfs shell

```bash
#!/bin/bash
#auther: kame
## Install fastdfs

FastDFS_DIR=/opt/fastdfs
yum makecache
yum -y install gettext gettext-devel libXft libXft-devel libXpm libXpm-devel automake autoconf libXtst-devel gtk+-devel gcc gcc-c++zlib-devel libpng-devel gtk2-devel glib-devel pcre* gcc git
mkdir -p $FastDFS_DIR
## create data1 data2
cd $FastDFS_DIR
git clone https://github.com/happyfish100/libfastcommon.git
cd libfastcommon
./make.sh
./make.sh install
echo "Finshed Install libfastcommon"
cd $FastDFS_DIR
git clone https://github.com/happyfish100/fastdfs.git
cd fastdfs
sed -i 's#/usr/local/bin/#/usr/bin/#g' init.d/fdfs_storaged
sed -i 's#/usr/local/bin/#/usr/bin/#g' init.d/fdfs_trackerd
./make.sh
./make.sh install
```

## [#](http://www.liuwq.com/views/存储/FastDFS_install.html#install-fastdfs-nginx-shell)Install Fastdfs_nginx shell

```bash
#!/bin/bash

nginx='nginx-1.7.9'
install_dir=/opt/nginx
fastdfs_dir=/opt/fastdfs
mkdir $install_dir
cd $install_dir
wget http://nginx.org/download/$nginx.tar.gz
git clone https://github.com/happyfish100/fastdfs-nginx-module.git
tar xf $nginx.tar.gz
cd $nginx

./configure --add-module=../fastdfs-nginx-module/src/ \
--prefix=/usr/local/nginx --user=nobody --group=nobody \
--with-http_gzip_static_module --with-http_gunzip_module
make -j8
make install

cp $install_dir/fastdfs-nginx-module/src/mod_fastdfs.conf /etc/fdfs/
cp $fastdfs_dir/fastdfs/conf/{anti-steal.jpg,http.conf,mime.types} /etc/fdfs/
touch /var/log/mod_fastdfs.log
chown nobody.nobody /var/log/mod_fastdfs.log
```