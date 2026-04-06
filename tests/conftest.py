import cellprofiler_core.preferences


def pytest_configure(config):
    """Set headless mode before test collection to prevent wx imports."""
    cellprofiler_core.preferences.set_headless()
