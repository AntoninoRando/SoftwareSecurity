#!/bin/bash

FUZZER_DIR="/fuzzing"
OUTPUT_DIR="$FUZZER_DIR/output"
# I've set the base crash directory to be one of the first fuzzer, but 
# using a cmd argument ($2 for avoiding conflicts with the tool name
# specification) other directories can be analyzed fast.
CRASHES_DIR="$OUTPUT_DIR/FUZZER_0/crashes"
IMAGEMAGICK_BIN="/usr/local/bin/magick"
ANALYSIS_DIR="$FUZZER_DIR/analysis"

echo "=== AFL++ Crash Analysis Tool ==="
echo "Crashes directory: $CRASHES_DIR"
echo "Analysis directory: $ANALYSIS_DIR"
echo "================================="

# Create analysis directory
mkdir -p "$ANALYSIS_DIR"

# Function to analyze a single crash
analyze_crash() {
    local crash_file="$1"
    local crash_name=$(basename "$crash_file")
    local analysis_file="$ANALYSIS_DIR/${crash_name}_analysis.txt"
    
    echo "Analyzing crash: $crash_name"
    echo "=================================" > "$analysis_file"
    echo "Crash Analysis Report" >> "$analysis_file"
    echo "Generated: $(date)" >> "$analysis_file"
    echo "Crash file: $crash_file" >> "$analysis_file"
    echo "=================================" >> "$analysis_file"
    echo "" >> "$analysis_file"
    
    # Basic file information
    echo "=== FILE INFORMATION ===" >> "$analysis_file"
    echo "File size: $(wc -c < "$crash_file") bytes" >> "$analysis_file"
    echo "File type: $(file "$crash_file")" >> "$analysis_file"
    echo "MD5 hash: $(md5sum "$crash_file" | cut -d' ' -f1)" >> "$analysis_file"
    echo "" >> "$analysis_file"
    
    # Hex dump of first 256 bytes
    echo "=== HEX DUMP (first 256 bytes) ===" >> "$analysis_file"
    head -c 256 "$crash_file" | hexdump -C >> "$analysis_file"
    echo "" >> "$analysis_file"
    
    # Try to run with GDB to get crash details
    echo "=== GDB CRASH ANALYSIS ===" >> "$analysis_file"
    echo "Running with GDB..." >> "$analysis_file"
    
    # Create GDB script
    local gdb_script="$ANALYSIS_DIR/gdb_commands.txt"
    cat > "$gdb_script" << 'EOF'
set confirm off
set pagination off
run
bt
info registers
x/32x $rsp
x/32x $rbp
quit
EOF
    
    # Run with GDB (timeout after 30 seconds)
    timeout 30 gdb --batch --command="$gdb_script" --args "$IMAGEMAGICK_BIN" "$crash_file" /dev/null >> "$analysis_file" 2>&1
    echo "" >> "$analysis_file"
    
    # Try to run with AddressSanitizer if available
    echo "=== CRASH REPRODUCTION ===" >> "$analysis_file"
    echo "Attempting to reproduce crash..." >> "$analysis_file"
    
    # Set up environment for crash reproduction
    export ASAN_OPTIONS="abort_on_error=1:print_stats=1:print_stacktrace=1"
    export MSAN_OPTIONS="abort_on_error=1:print_stats=1"
    
    # Try to reproduce the crash with timeout
    timeout 10 "$IMAGEMAGICK_BIN" "$crash_file" /dev/null >> "$analysis_file" 2>&1
    local exit_code=$?
    echo "Exit code: $exit_code" >> "$analysis_file"
    echo "" >> "$analysis_file"
    
    # Analyze crash type based on exit code and output
    echo "=== CRASH TYPE ANALYSIS ===" >> "$analysis_file"
    case $exit_code in
        139) echo "Crash type: SIGSEGV (Segmentation fault) - Potential memory corruption" >> "$analysis_file" ;;
        134) echo "Crash type: SIGABRT (Abort) - Potential assertion failure or heap corruption" >> "$analysis_file" ;;
        132) echo "Crash type: SIGILL (Illegal instruction) - Potential code corruption" >> "$analysis_file" ;;
        136) echo "Crash type: SIGFPE (Floating point exception) - Potential division by zero" >> "$analysis_file" ;;
        *) echo "Crash type: Unknown (exit code $exit_code)" >> "$analysis_file" ;;
    esac
    echo "" >> "$analysis_file"
    
    # CVE potential assessment
    echo "=== CVE POTENTIAL ASSESSMENT ===" >> "$analysis_file"
    assess_cve_potential "$crash_file" >> "$analysis_file"
    echo "" >> "$analysis_file"
    
    # Generate minimized test case
    echo "=== TEST CASE MINIMIZATION ===" >> "$analysis_file"
    minimize_crash "$crash_file" >> "$analysis_file"
    
    echo "Analysis complete. Report saved to: $analysis_file"
}

# Function to assess CVE potential
assess_cve_potential() {
    local crash_file="$1"
    
    echo "Assessing CVE potential..."
    echo ""
    
    # Check for common vulnerability patterns
    local has_segfault=false
    local has_heap_corruption=false
    local has_buffer_overflow=false
    local has_format_string=false
    
    # Run quick tests to identify vulnerability types
    timeout 5 "$IMAGEMAGICK_BIN" "$crash_file" /dev/null 2>&1 | grep -q "SIGSEGV\|Segmentation fault" && has_segfault=true
    timeout 5 "$IMAGEMAGICK_BIN" "$crash_file" /dev/null 2>&1 | grep -q "heap\|malloc\|free" && has_heap_corruption=true
    timeout 5 "$IMAGEMAGICK_BIN" "$crash_file" /dev/null 2>&1 | grep -q "buffer\|overflow\|overrun" && has_buffer_overflow=true
    timeout 5 "$IMAGEMAGICK_BIN" "$crash_file" /dev/null 2>&1 | grep -q "format\|printf" && has_format_string=true
    
    echo "VULNERABILITY INDICATORS:"
    echo "------------------------"
    echo "Segmentation fault: $has_segfault"
    echo "Heap corruption: $has_heap_corruption"
    echo "Buffer overflow: $has_buffer_overflow"
    echo "Format string: $has_format_string"
    echo ""
    
    # Calculate risk score
    local risk_score=0
    $has_segfault && risk_score=$((risk_score + 3))
    $has_heap_corruption && risk_score=$((risk_score + 4))
    $has_buffer_overflow && risk_score=$((risk_score + 4))
    $has_format_string && risk_score=$((risk_score + 5))
    
    echo "RISK ASSESSMENT:"
    echo "---------------"
    if [ $risk_score -ge 7 ]; then
        echo "HIGH RISK - Likely exploitable vulnerability"
        echo "Recommendation: Immediate investigation required"
    elif [ $risk_score -ge 4 ]; then
        echo "MEDIUM RISK - Potential vulnerability"
        echo "Recommendation: Further analysis needed"
    elif [ $risk_score -ge 1 ]; then
        echo "LOW RISK - Minor issue"
        echo "Recommendation: Monitor for patterns"
    else
        echo "MINIMAL RISK - Likely false positive"
        echo "Recommendation: Can be deprioritized"
    fi
    echo ""
    
    echo "CVE POTENTIAL CHECKLIST:"
    echo "----------------------"
    echo "✓ Check if crash is reproducible"
    echo "✓ Verify crash occurs in latest version"
    echo "✓ Determine if crash is exploitable"
    echo "✓ Check if vulnerability affects confidentiality/integrity/availability"
    echo "✓ Search existing CVE databases"
    echo "✓ Create minimal proof-of-concept"
    echo "✓ Follow responsible disclosure process"
}

# Function to minimize crash
minimize_crash() {
    local crash_file="$1"
    local crash_name=$(basename "$crash_file")
    local min_file="$ANALYSIS_DIR/${crash_name}_minimized"
    
    echo "Attempting to minimize crash file..."
    
    # Use afl-tmin if available
    if command -v afl-tmin >/dev/null 2>&1; then
        echo "Using afl-tmin for minimization..."
        timeout 300 afl-tmin -i "$crash_file" -o "$min_file" -- "$IMAGEMAGICK_BIN" @@ /dev/null 2>&1
        
        if [ -f "$min_file" ]; then
            local orig_size=$(wc -c < "$crash_file")
            local min_size=$(wc -c < "$min_file")
            echo "Original size: $orig_size bytes"
            echo "Minimized size: $min_size bytes"
            echo "Reduction: $(( (orig_size - min_size) * 100 / orig_size ))%"
            echo "Minimized file: $min_file"
        else
            echo "Minimization failed"
        fi
    else
        echo "afl-tmin not available, skipping minimization"
    fi
}

# Function to search for existing CVEs
search_existing_cves() {
    local crash_file="$1"
    
    echo "Searching for existing CVEs..."
    echo "Note: This requires manual research in:"
    echo "- CVE Database (https://cve.mitre.org/)"
    echo "- NVD (https://nvd.nist.gov/)"
    echo "- ImageMagick security advisories"
    echo "- GitHub security advisories"
    echo ""
    echo "Search keywords to use:"
    echo "- ImageMagick $(magick -version | head -1)"
    echo "- File format: $(file "$crash_file")"
    echo "- Crash type: segmentation fault, heap corruption, etc."
}

# Function to generate CVE report template
generate_cve_report() {
    local crash_file="$1"
    local crash_name=$(basename "$crash_file")
    local report_file="$ANALYSIS_DIR/${crash_name}_cve_report.md"
    
    cat > "$report_file" << EOF
# Potential CVE Report: $crash_name

## Summary
- **Product**: ImageMagick
- **Version**: $(magick -version | head -1)
- **Vulnerability Type**: [To be determined]
- **Severity**: [To be assessed]
- **Date Found**: $(date)

## Description
[Describe the vulnerability]

## Reproduction Steps
1. Use the crash file: \`$crash_file\`
2. Run: \`magick $crash_file /dev/null\`
3. Observe crash/unexpected behavior

## Impact
- [ ] Denial of Service (DoS)
- [ ] Information Disclosure
- [ ] Code Execution
- [ ] Privilege Escalation

## Technical Details
- **Crash Type**: [SIGSEGV/SIGABRT/etc.]
- **Affected Component**: [Image parser/decoder/etc.]
- **Root Cause**: [Buffer overflow/heap corruption/etc.]

## Proof of Concept
\`\`\`bash
# Minimal reproduction command
magick [crash_file] /dev/null
\`\`\`

## Mitigation
[Suggested fixes or workarounds]

## References
- Crash analysis report: \`$(basename "$analysis_file")\`
- Minimized test case: \`${crash_name}_minimized\`

## Disclosure Timeline
- **Discovery**: $(date)
- **Vendor Contact**: [Date]
- **Vendor Response**: [Date]
- **Fix Release**: [Date]
- **Public Disclosure**: [Date]
EOF

    echo "CVE report template generated: $report_file"
}

# Main script logic
case "$1" in
    "analyze")
        if [ -z "$2" ]; then
            echo "Usage: $0 analyze <crash_file>"
            echo "Available crashes:"
            ls -la "$CRASHES_DIR/" 2>/dev/null || echo "No crashes found"
            exit 1
        fi
        analyze_crash "$2"
        ;;
    "analyze-all")
        if [ ! -d "$CRASHES_DIR" ]; then
            echo "No crashes directory found"
            exit 1
        fi
        
        crash_count=$(ls -1 "$CRASHES_DIR" | wc -l)
        echo "Found $crash_count crashes to analyze"
        
        for crash_file in "$CRASHES_DIR"/*; do
            if [ -f "$crash_file" ]; then
                analyze_crash "$crash_file"
            fi
        done
        ;;
    "search-cves")
        if [ -z "$2" ]; then
            echo "Usage: $0 search-cves <crash_file>"
            exit 1
        fi
        search_existing_cves "$2"
        ;;
    "report")
        if [ -z "$2" ]; then
            echo "Usage: $0 report <crash_file>"
            exit 1
        fi
        generate_cve_report "$2"
        ;;
    "list")
        echo "Available crashes:"
        ls -la "$CRASHES_DIR/" 2>/dev/null || echo "No crashes found"
        ;;
    *)
        echo "Usage: $0 {analyze|analyze-all|search-cves|report|list} [crash_file]"
        echo ""
        echo "Commands:"
        echo "  analyze <file>    - Analyze specific crash file"
        echo "  analyze-all       - Analyze all crashes"
        echo "  search-cves <file> - Search for existing CVEs"
        echo "  report <file>     - Generate CVE report template"
        echo "  list              - List available crashes"
        ;;
esac