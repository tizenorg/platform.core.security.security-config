Name:           security-config
Summary:        A set of security configuration files
Version:        1.0
Release:        1
License:        Apache-2.0
Group:          Security/Configuration
Source0:        %{name}-%{version}.tar.gz
Source1:        %{name}.manifest
BuildRequires:  cmake
Requires:       shadow-utils
Requires:       libcap-tools

%description
set of important system configuration and
setup files, such as passwd, group, and profile.

%prep
%setup -q

%build

%cmake . -DARCH=%{_arch} \
	-DSYSTEMD_UNIT_DIR:PATH=%{_unitdir} \
	-DPROFILE=%{profile}

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{_datadir}/license
cp LICENSE %{buildroot}%{_datadir}/license/%{name}
cp LICENSE %{buildroot}%{_datadir}/license/security-config
%make_install

mkdir -p %{buildroot}%{_libdir}/systemd/system/multi-user.target.wants
ln -s ../%{name}.service %{buildroot}%{_libdir}/systemd/system/multi-user.target.wants/%{name}.service

%post
/usr/share/security-config/group_id_setting
/usr/share/security-config/set_label
mkdir -p /usr/share/security-config/result
mkdir -p /usr/share/security-config/log

%files -n security-config
%manifest %{_datadir}/%{name}.manifest
%{_datadir}/license/%{name}
%defattr(-,root,root,-)
%attr(755,root,root) /usr/share/security-config/group_id_setting
%attr(755,root,root) /usr/share/security-config/set_label
%attr(755,root,root) /usr/share/security-config/set_capability
%attr(644,root,root) /usr/lib/tmpfiles.d/security-config.conf
#%attr(755,root,root) /usr/share/security-config/test/aslr_test/*
%attr(755,root,root) /usr/share/security-config/test/utils/*
#%attr(755,root,root) /usr/share/security-config/test/dep_test/*
%attr(755,root,root) /usr/share/security-config/test/setuid_test/*
%attr(755,root,root) /usr/share/security-config/test/smack_rule_test/*
%attr(755,root,root) /usr/share/security-config/test/root_test/*
%attr(755,root,root) /usr/share/security-config/test/capability_test/*
%attr(755,root,root) /usr/share/security-config/test/path_check_test/*
%attr(755,root,root) /usr/share/security-config/test/smack_basic_test/*
%attr(755,root,root) /usr/share/security-config/test/security_mount_option_test/*
%attr(755,root,root) %{_sysconfdir}/gumd/useradd.d/90_user-content-permissions.post
%attr(755,root,root) %{_sysconfdir}/gumd/useradd.d/91_user-dbspace-permissions.post
%attr(-,root,root) %{_unitdir}/security-config.service
%attr(-,root,root) %{_unitdir}/multi-user.target.wants/security-config.service
%attr(755,root,root) /usr/share/security-config/smack_default_labeling
