"""
Tests for pynyschooldata Python wrapper.

Minimal smoke tests - the actual data logic is tested by R testthat.
These just verify the Python wrapper imports and exposes expected functions.
"""

import pytest


def test_import_package():
    """Package imports successfully."""
    import pynyschooldata
    assert pynyschooldata is not None


def test_has_fetch_enr():
    """fetch_enr function is available."""
    import pynyschooldata
    assert hasattr(pynyschooldata, 'fetch_enr')
    assert callable(pynyschooldata.fetch_enr)


def test_has_get_available_years():
    """get_available_years function is available."""
    import pynyschooldata
    assert hasattr(pynyschooldata, 'get_available_years')
    assert callable(pynyschooldata.get_available_years)


def test_has_version():
    """Package has a version string."""
    import pynyschooldata
    assert hasattr(pynyschooldata, '__version__')
    assert isinstance(pynyschooldata.__version__, str)
