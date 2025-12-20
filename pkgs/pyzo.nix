{
	lib,
	fetchPypi,
	qtbase,
	wrapQtAppsHook,
	python3Packages,
}:

python3Packages.buildPythonApplication rec {
	pname = "pyzo";
	version = "4.16.0";
	pyproject = true;

	src = fetchPypi {
		inherit pname version;
		hash = "sha256-Df6vduJ9bxKuUGeXn8sV8peLDAB4EKtF5LnAzpv+yQo=";
	};

	doCheck = false;

	propagatedBuildInputs = [ python3Packages.pyside6 ];
	buildInputs = [	qtbase ];
	nativeBuildInputs = [ wrapQtAppsHook ];

	build-system = with python3Packages; [
		setuptools
		wheel
	];
}
