#!/usr/bin/env python3
"""
BaiduPCS-Go Playwright Login Helper

Automates Baidu Netdisk QR code authentication using Playwright (Chromium headless),
captures session cookies (BDUSS, STOKEN), and authenticates BaiduPCS-Go.
"""

import argparse
import json
import os
import shutil
import subprocess
import sys
import time


def find_baidupcs_bin(user_specified=None):
    if user_specified and os.path.isfile(user_specified) and os.access(user_specified, os.X_OK):
        return user_specified
    
    # Check in PATH
    found = shutil.which("BaiduPCS-Go") or shutil.which("baidupcs-go")
    if found:
        return found
    
    # Check standard local install locations
    home = os.path.expanduser("~")
    candidates = [
        os.path.join(home, ".local", "bin", "BaiduPCS-Go"),
        os.path.join(home, ".pixi", "bin", "BaiduPCS-Go"),
        os.path.join(home, "bin", "BaiduPCS-Go"),
        "/usr/local/bin/BaiduPCS-Go",
    ]
    for c in candidates:
        if os.path.isfile(c) and os.access(c, os.X_OK):
            return c
            
    return "BaiduPCS-Go"


def save_qr(page, qr_path):
    os.makedirs(os.path.dirname(os.path.abspath(qr_path)), exist_ok=True)
    qr_img = page.locator("img[src*='qrcode'], img[src*='passport.baidu.com/v2/api/qrcode']")
    if qr_img.count() > 0 and qr_img.first.is_visible():
        try:
            qr_img.first.screenshot(path=qr_path)
            print(f"[+] Saved QR code screenshot to: {qr_path}")
            return True
        except Exception as e:
            print(f"[-] Failed to screenshot QR locator ({e}), falling back to full page screenshot.")
            
    page.screenshot(path=qr_path)
    print(f"[+] Saved page screenshot to: {qr_path}")
    return True


def run_login(qr_path, baidupcs_bin, timeout=600, save_cookies_path=None):
    try:
        from playwright.sync_api import sync_playwright
    except ImportError:
        print("[-] Playwright is not installed. Install via: pip install playwright && playwright install chromium")
        sys.exit(1)

    print(f"[*] Target BaiduPCS-Go binary: {baidupcs_bin}")
    print("[*] Starting Playwright Chromium in headless mode...")

    with sync_playwright() as p:
        browser = p.chromium.launch(
            headless=True,
            args=[
                "--no-sandbox",
                "--disable-setuid-sandbox",
                "--disable-dev-shm-usage",
                "--disable-gpu",
            ],
        )
        context = browser.new_context(
            user_agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
            viewport={"width": 1280, "height": 800},
        )
        page = context.new_page()

        print("[*] Navigating to https://pan.baidu.com/ ...")
        page.goto("https://pan.baidu.com/", wait_until="networkidle", timeout=30000)

        # Click login button if present
        login_btn = page.locator("text=去登录")
        if login_btn.count() > 0 and login_btn.first.is_visible():
            print("[*] Opening login modal...")
            login_btn.first.click()
            time.sleep(2)

        # Agree to terms checkbox if present
        checkboxes = page.locator("input[type=\"checkbox\"]")
        for i in range(checkboxes.count()):
            try:
                checkboxes.nth(i).check(force=True)
            except Exception:
                pass

        time.sleep(1)
        save_qr(page, qr_path)
        print(f"\n[+] Login QR code is ready at: {qr_path}")
        print("[+] Please scan the QR code using Baidu Netdisk Mobile App (百度网盘) or Baidu App (百度).\n")

        # Polling for login authentication
        start_time = time.time()
        logged_in = False
        last_refresh_check = time.time()

        while time.time() - start_time < timeout:
            cookies = context.cookies()
            cookie_dict = {c["name"]: c["value"] for c in cookies}

            if "BDUSS" in cookie_dict or "BDUSS_BFESS" in cookie_dict:
                print("\n[+] Authentication cookie (BDUSS) detected! Login confirmed.")
                time.sleep(2)
                logged_in = True
                break

            # Handle QR expiration check
            if time.time() - last_refresh_check > 15:
                last_refresh_check = time.time()
                refresh_loc = page.locator("p.Qrcode-refresh-btn, text='二维码已失效'")
                if refresh_loc.count() > 0 and refresh_loc.first.is_visible():
                    try:
                        print("[*] QR code expired on page. Refreshing...")
                        refresh_loc.first.click(timeout=3000, force=True)
                        time.sleep(2)
                        save_qr(page, qr_path)
                        print("[*] Refreshed QR code saved.")
                    except Exception as e:
                        print(f"[-] QR refresh error: {e}")

            time.sleep(1)

        if not logged_in:
            print(f"[-] Timed out after {timeout} seconds waiting for QR code scan.")
            browser.close()
            return False

        # Navigate to disk home to ensure STOKEN cookie is populated
        try:
            page.goto("https://pan.baidu.com/disk/main", wait_until="networkidle", timeout=15000)
            time.sleep(2)
        except Exception:
            pass

        cookies = context.cookies()
        cookie_dict = {c["name"]: c["value"] for c in cookies}
        cookie_string = "; ".join([f"{c['name']}={c['value']}" for c in cookies])

        bduss = cookie_dict.get("BDUSS", cookie_dict.get("BDUSS_BFESS", ""))
        stoken = cookie_dict.get("STOKEN", "")
        print(f"[+] BDUSS captured: {bduss[:8]}... (length {len(bduss)})")
        print(f"[+] STOKEN captured: {stoken[:8]}... (length {len(stoken)})")

        if save_cookies_path:
            os.makedirs(os.path.dirname(os.path.abspath(save_cookies_path)), exist_ok=True)
            with open(save_cookies_path, "w", encoding="utf-8") as f:
                json.dump(cookies, f, indent=2, ensure_ascii=False)
            print(f"[+] Saved raw cookies to {save_cookies_path}")

        browser.close()

        # Execute BaiduPCS-Go login
        print(f"[*] Running: {baidupcs_bin} login -cookies=...")
        login_res = subprocess.run([baidupcs_bin, "login", f"-cookies={cookie_string}"], capture_output=True, text=True)
        print("Login Output:\n", login_res.stdout)
        if login_res.stderr:
            print("Login Stderr:\n", login_res.stderr)

        # Output account information
        print("[*] Verifying account:")
        subprocess.run([baidupcs_bin, "who"])
        subprocess.run([baidupcs_bin, "quota"])
        return True


def main():
    parser = argparse.ArgumentParser(description="Baidu Netdisk Playwright QR login helper for BaiduPCS-Go")
    parser.add_argument("--qr-path", default="./qrcode.png", help="Path where QR code screenshot will be saved (default: ./qrcode.png)")
    parser.add_argument("--baidupcs-bin", default=None, help="Path to BaiduPCS-Go executable (default: search in PATH and ~/.local/bin)")
    parser.add_argument("--timeout", type=int, default=600, help="Timeout in seconds to wait for QR scan (default: 600)")
    parser.add_argument("--save-cookies", default=None, help="Optional file path to store exported cookies as JSON")
    args = parser.parse_args()

    bin_path = find_baidupcs_bin(args.baidupcs_bin)
    success = run_login(
        qr_path=os.path.abspath(args.qr_path),
        baidupcs_bin=bin_path,
        timeout=args.timeout,
        save_cookies_path=args.save_cookies,
    )
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
