version=$(head -n 5 pubspec.yaml | tail -n 1 | cut -d ' ' -f 2)

flutter build macos --release -t lib/src/main.dart \
&& hdiutil create -size 150m -fs HFS+ -volname JHenTaiX JHenTaiX.dmg \
&& hdiutil attach JHenTaiX.dmg \
&& cp -R build/macos/Build/Products/Release/JHenTaiX.app /Volumes/JHenTaiX \
&& pkgbuild --install-location /Applications/JHenTaiX.app --identifier top.jtmonster.jhentaix --version ${version} --root /Volumes/JHenTaiX/JHenTaiX.app build/macos/JHenTaiX-${version}.pkg \
&& hdiutil detach /Volumes/JHenTaiX
