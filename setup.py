from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setup(
    name='ldap_sam_syncd',
    version='0.0.1',
    packages=find_packages(),
    install_requires=[
        'syncrepl_client>=0.95.1',
    ],
    author='George B Williams',
    author_email='gwilliam@ucar.edu',
    python_requires='>=3.9',
    description='LDAP-to-SAM synchronization service.',
    long_description=long_description,
    long_description_content_type="text/markdown",
    project_urls={
        'Source': 'https://github.com/NCAR/ldap-sam-syncd/',
    },
)
