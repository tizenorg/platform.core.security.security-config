Name:           security-config
Summary:     A set of security configuration files
Version:        1.0
Release:        1
License:        Apache-2.0
Group:          System/Security
Source0:        %{name}-%{version}.tar.gz
Source1:     %{name}.manifest
BuildRequires:  cmake
Requires:       pwdutils

%description
set of important system configuration and
setup files, such as passwd, group, and profile.

%prep
%setup -q

%build

%cmake .

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{_datadir}/license
cp LICENSE %{buildroot}%{_datadir}/license/%{name}
cp LICENSE %{buildroot}%{_datadir}/license/security-config
%make_install

%post
/usr/share/security-config/group_id_setting
/usr/share/security-config/set_label

%files -n security-config
%manifest %{_datadir}/%{name}.manifest
%{_datadir}/license/%{name}
%defattr(-,root,root,-)
%attr(755,root,root) /usr/share/security-config/group_id_setting
%attr(755,root,root) /usr/share/security-config/set_label
%attr(755,root,root) %{_sysconfdir}/gumd/useradd.d/91_user-dbspace-permissions.post

