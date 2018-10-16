# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python{2_7,3_{4,5,6,7}} )

inherit meson python-any-r1 udev

DESCRIPTION="Library to handle input devices in Wayland"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/libinput/"
SRC_URI="https://www.freedesktop.org/software/${PN}/${P}.tar.xz"

LICENSE="MIT"
SLOT="0/10"
KEYWORDS="~amd64 ~x86"
IUSE="doc input_devices_wacom"
# Tests require write access to udev rules directory which is a no-no for live system.
# Other tests are just about logs, exported symbols and autotest of the test library.
RESTRICT="test"

RDEPEND="
	input_devices_wacom? ( >=dev-libs/libwacom-0.20 )
	>=dev-libs/libevdev-1.3
	>=sys-libs/mtdev-1.1
	virtual/libudev:=
	virtual/udev
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? (
		$(python_gen_any_dep '
			dev-python/CommonMark[${PYTHON_USEDEP}]
			dev-python/recommonmark[${PYTHON_USEDEP}]
			dev-python/sphinx[${PYTHON_USEDEP}]
		')
		>=app-doc/doxygen-1.8.3
		>=media-gfx/graphviz-2.38.0
	)
"
#	test? (
#		>=dev-libs/check-0.9.10
#		dev-util/valgrind
#		sys-libs/libunwind )

python_check_deps() {
	has_version "dev-python/CommonMark[${PYTHON_USEDEP}]" && \
	has_version "dev-python/recommonmark[${PYTHON_USEDEP}]" && \
	has_version "dev-python/sphinx[${PYTHON_USEDEP}]"
}

pkg_setup() {
	use doc && python-any-r1_pkg_setup
}

src_configure() {
	# gui can be built but will not be installed
	local emesonargs=(
		-Ddebug-gui=false
		$(meson_use doc documentation)
		$(meson_use input_devices_wacom libwacom)
		-Dtests=false # tests are restricted
		-Dudev-dir="$(get_udevdir)"
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	if use doc ; then
		docinto html
		dodoc -r "${BUILD_DIR}"/Documentation/.
	fi
}

pkg_postinst() {
	udevadm hwdb --update --root="${ROOT%/}"
}