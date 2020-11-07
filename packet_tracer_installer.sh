#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

last_dir=$(pwd)
pt_deb=$1
pt_instal=/opt/pt
pt_launcher=/usr/share/applications/cisco-pt7.desktop
ptsa_launcher=/usr/share/applications/cisco-ptsa7.desktop
pt_icon=/usr/share/icons/hicolor/48x48/apps/pt7.png
libdouble_conversion=/usr/lib64/libdouble-conversion.so.1

if  [ ! -f "$pt_deb" ]; then   
    echo "$pt_deb does not exists."
    exit
fi

# still need a validation if this real packet tracer deb archive

echo "Extracting..."
mkdir /tmp/PacketTracerInst;
cp $pt_deb /tmp/PacketTracerInst
cd /tmp/PacketTracerInst
ar -xv $pt_deb
mkdir control
tar -C control -Jxf control.tar.xz
mkdir data
tar -C data -Jxf data.tar.xz
cd data

echo "Uninstalling old installation (if exists)..."
if [ -d "$pt_instal" ]; then
    sudo rm -rf $pt_instal
fi
if [ -d "$pt_launcher" ]; then
    sudo rm -rf $pt_launcher
fi
if [ -d "$ptsa_launcher" ]; then
    rm -rf $ptsa_launcher
fi
if [ -d "$pt_icon" ]; then
    rm -rf $pt_icon
fi

echo "Installing..."
cp -r usr /
cp -r opt /

if  [ ! -f "$libdouble_conversion" ]; then   
    ln -s /usr/lib64/libdouble-conversion.so.3 $libdouble_conversion
fi

echo "Updating icon and file association..."
xdg-desktop-menu install /usr/share/applications/cisco-pt7.desktop
xdg-desktop-menu install /usr/share/applications/cisco-ptsa7.desktop
update-mime-database /usr/share/mime
gtk-update-icon-cache --force --ignore-theme-index /usr/share/icons/gnome
xdg-mime default cisco-ptsa7.desktop x-scheme-handler/pttp
ln -sf /opt/pt/packettracer /usr/local/bin/packettracer

# Mostly work for openSUSE Tumbleweed, I don't know for other distribution
echo "Setting variable environment..."
echo "#!/bin/bash " >> /etc/profile.d/packet_tracer.sh
echo "PT7HOME=/opt/pt" >> /etc/profile.d/packet_tracer.sh 
echo "export PT7HOME" >> /etc/profile.d/packet_tracer.sh
echo "QT_DEVICE_PIXEL_RATIO=auto" >> /etc/profile.d/packet_tracer.sh
echo "export QT_DEVICE_PIXEL_RATIO" >> /etc/profile.d/packet_tracer.sh
chmod 0644 /etc/profile.d/packet_tracer.sh
chmod +x /etc/profile.d/packet_tracer.sh

echo "All done!"
echo "Please restart your computer!"
cd $last_dir