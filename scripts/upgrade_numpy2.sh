#!/usr/bin/env bash
#
# upgrade_numpy2.sh — Apply mass find-and-replace upgrades for NumPy 2.0 compatibility
#
# Usage: ./scripts/upgrade_numpy2.sh [target_dir ...]
#   If no target directories are given, defaults to src/ and tests/
#
# This script is idempotent — safe to run multiple times.
# It only modifies .py files.
#

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ $# -gt 0 ]; then
    TARGETS=("$@")
else
    TARGETS=("$REPO_ROOT/src" "$REPO_ROOT/tests")
fi

replace_in_py_files() {
    local pattern="$1"
    local sed_expr="$2"
    local description="$3"

    local files
    files=$(grep -rl "$pattern" "${TARGETS[@]}" --include='*.py' 2>/dev/null)
    if [ -n "$files" ]; then
        echo "$files" | xargs sed -i '' -E "$sed_expr"
        local count
        count=$(echo "$files" | wc -l | tr -d ' ')
        echo "  ✓ $description ($count files)"
    else
        echo "  – $description (no matches)"
    fi
}

echo "Applying NumPy 2.0 compatibility upgrades..."
echo "Targets: ${TARGETS[*]}"
echo ""

# --------------------------------------------------------------------------
# np.NaN / numpy.NaN → np.nan / numpy.nan
# Removed in NumPy 2.0. Use the lowercase versions instead.
# --------------------------------------------------------------------------
replace_in_py_files \
    'np\.NaN\|numpy\.NaN' \
    's/np\.NaN/np.nan/g; s/numpy\.NaN/numpy.nan/g' \
    "np.NaN / numpy.NaN → np.nan / numpy.nan (removed in NumPy 2.0)"

# --------------------------------------------------------------------------
# np.product( / numpy.product( → np.prod( / numpy.prod(
# np.product was a deprecated alias for np.prod, removed in NumPy 2.0.
# --------------------------------------------------------------------------
replace_in_py_files \
    'np\.product(\|numpy\.product(' \
    's/np\.product\(/np.prod(/g; s/numpy\.product\(/numpy.prod(/g' \
    "np.product() / numpy.product() → np.prod() / numpy.prod() (removed in NumPy 2.0)"

# --------------------------------------------------------------------------
# np.Inf / numpy.Inf → np.inf / numpy.inf
# np.Inf was a deprecated alias for np.inf, removed in NumPy 2.0.
# We match np.Inf not followed by 'i' to avoid clobbering np.Infinity/np.info.
# --------------------------------------------------------------------------
replace_in_py_files \
    'np\.Inf\|numpy\.Inf' \
    's/np\.Inf([^i])/np.inf\1/g; s/numpy\.Inf([^i])/numpy.inf\1/g; s/np\.Inf$/np.inf/g; s/numpy\.Inf$/numpy.inf/g' \
    "np.Inf / numpy.Inf → np.inf / numpy.inf (removed in NumPy 2.0)"

# --------------------------------------------------------------------------
# np.NAN / numpy.NAN → np.nan / numpy.nan
# np.NAN (all caps) was also removed in NumPy 2.0.
# --------------------------------------------------------------------------
replace_in_py_files \
    'np\.NAN\|numpy\.NAN' \
    's/np\.NAN/np.nan/g; s/numpy\.NAN/numpy.nan/g' \
    "np.NAN / numpy.NAN → np.nan / numpy.nan (removed in NumPy 2.0)"

# --------------------------------------------------------------------------
# np.in1d( / numpy.in1d( → np.isin( / numpy.isin(
# np.in1d was removed in NumPy 2.0. np.isin is the replacement.
# Note: np.isin has the same signature for the common case.
# --------------------------------------------------------------------------
replace_in_py_files \
    'np\.in1d(\|numpy\.in1d(' \
    's/np\.in1d\(/np.isin(/g; s/numpy\.in1d\(/numpy.isin(/g' \
    "np.in1d() / numpy.in1d() → np.isin() / numpy.isin() (removed in NumPy 2.0)"

# --------------------------------------------------------------------------
# np.core.records → np.rec
# numpy.core is deprecated in NumPy 2.0. np.rec is the public API.
# --------------------------------------------------------------------------
replace_in_py_files \
    'np\.core\.records\|numpy\.core\.records' \
    's/np\.core\.records/np.rec/g; s/numpy\.core\.records/numpy.rec/g' \
    "np.core.records / numpy.core.records → np.rec / numpy.rec (numpy.core deprecated in NumPy 2.0)"

# --------------------------------------------------------------------------
# scipy.sparse.coo.coo_matrix → scipy.sparse.coo_matrix
# scipy.sparse.coo submodule namespace is deprecated, removed in SciPy 2.0.
# --------------------------------------------------------------------------
replace_in_py_files \
    'scipy\.sparse\.coo\.coo_matrix' \
    's/scipy\.sparse\.coo\.coo_matrix/scipy.sparse.coo_matrix/g' \
    "scipy.sparse.coo.coo_matrix → scipy.sparse.coo_matrix (deprecated namespace)"

# --------------------------------------------------------------------------
# scipy.ndimage.filters.X → scipy.ndimage.X
# scipy.ndimage.filters namespace is deprecated, removed in SciPy 2.0.
# --------------------------------------------------------------------------
replace_in_py_files \
    'scipy\.ndimage\.filters\.' \
    's/scipy\.ndimage\.filters\./scipy.ndimage./g' \
    "scipy.ndimage.filters.X → scipy.ndimage.X (deprecated namespace)"

# --------------------------------------------------------------------------
# scipy.ndimage.measurements.X → scipy.ndimage.X
# scipy.ndimage.measurements namespace is deprecated, removed in SciPy 2.0.
# --------------------------------------------------------------------------
replace_in_py_files \
    'scipy\.ndimage\.measurements\.' \
    's/scipy\.ndimage\.measurements\./scipy.ndimage./g' \
    "scipy.ndimage.measurements.X → scipy.ndimage.X (deprecated namespace)"

# --------------------------------------------------------------------------
# scipy.io.matlab.mio.savemat → scipy.io.savemat
# scipy.io.matlab.mio namespace is deprecated, removed in SciPy 2.0.
# --------------------------------------------------------------------------
replace_in_py_files \
    'scipy\.io\.matlab\.mio\.savemat' \
    's/scipy\.io\.matlab\.mio\.savemat/scipy.io.savemat/g' \
    "scipy.io.matlab.mio.savemat → scipy.io.savemat (deprecated namespace)"

echo ""
echo "Done."
