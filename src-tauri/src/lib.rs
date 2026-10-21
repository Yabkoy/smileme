use std::{thread, time::Duration};

use tauri::{
    menu::{Menu, MenuItem},
    tray::TrayIconBuilder,
    AppHandle, Manager, WindowEvent,
};

#[cfg(desktop)]
use tauri_plugin_global_shortcut::{Code, GlobalShortcutExt, Modifiers, Shortcut, ShortcutState};

const MAIN_WINDOW: &str = "main";

fn show_picker(app: &AppHandle) {
    if let Some(window) = app.get_webview_window(MAIN_WINDOW) {
        let _ = window.unminimize();
        let _ = window.center();
        let _ = window.show();
        let _ = window.set_always_on_top(true);
        let _ = window.set_focus();
    }
}

fn hide_picker(app: &AppHandle) {
    if let Some(window) = app.get_webview_window(MAIN_WINDOW) {
        let _ = window.hide();
    }
}

fn toggle_picker(app: &AppHandle) {
    if let Some(window) = app.get_webview_window(MAIN_WINDOW) {
        if window.is_visible().unwrap_or(false) {
            hide_picker(app);
        } else {
            show_picker(app);
        }
    }
}

/// Symuluje Ctrl+V (Cmd+V na macOS) w aktualnie aktywnej aplikacji.
fn simulate_paste() {
    use enigo::{Direction, Enigo, Key, Keyboard, Settings};

    let Ok(mut enigo) = Enigo::new(&Settings::default()) else {
        return;
    };

    #[cfg(target_os = "macos")]
    let modifier = Key::Meta;
    #[cfg(not(target_os = "macos"))]
    let modifier = Key::Control;

    // Na Windows używamy kodu VK_V, żeby działało niezależnie od układu klawiatury
    #[cfg(target_os = "windows")]
    let v = Key::Other(0x56);
    #[cfg(not(target_os = "windows"))]
    let v = Key::Unicode('v');

    let _ = enigo.key(modifier, Direction::Press);
    let _ = enigo.key(v, Direction::Click);
    let _ = enigo.key(modifier, Direction::Release);
}

/// Wywoływane z frontendu po skopiowaniu emoji do schowka:
/// chowa picker, czeka aż system odda focus poprzedniej aplikacji i wkleja.
#[tauri::command]
fn paste_and_hide(app: AppHandle) {
    hide_picker(&app);

    // macOS: samo ukrycie okna nie oddaje focusa, trzeba schować całą aplikację
    #[cfg(target_os = "macos")]
    let _ = app.hide();

    let app_for_thread = app.clone();
    thread::spawn(move || {
        thread::sleep(Duration::from_millis(150));
        let _ = app_for_thread.run_on_main_thread(simulate_paste);
    });
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .invoke_handler(tauri::generate_handler![paste_and_hide])
        .setup(|app| {
            // macOS: aplikacja bez ikony w Docku, nie kradnie focusa innym programom
            #[cfg(target_os = "macos")]
            app.set_activation_policy(tauri::ActivationPolicy::Accessory);

            #[cfg(desktop)]
            {
                let picker_shortcut = Shortcut::new(Some(Modifiers::ALT), Code::Period);

                app.handle().plugin(
                    tauri_plugin_global_shortcut::Builder::new()
                        .with_handler(move |app, shortcut, event| {
                            if shortcut == &picker_shortcut
                                && event.state() == ShortcutState::Pressed
                            {
                                toggle_picker(app);
                            }
                        })
                        .build(),
                )?;

                app.global_shortcut().register(picker_shortcut)?;
            }

            let show_item = MenuItem::with_id(app, "show", "Pokaż picker", true, None::<&str>)?;
            let quit_item = MenuItem::with_id(app, "quit", "Zakończ", true, None::<&str>)?;
            let menu = Menu::with_items(app, &[&show_item, &quit_item])?;

            TrayIconBuilder::new()
                .icon(app.default_window_icon().unwrap().clone())
                .tooltip("Emoji Picker (Alt+.)")
                .menu(&menu)
                .on_menu_event(|app, event| match event.id.as_ref() {
                    "show" => show_picker(app),
                    "quit" => app.exit(0),
                    _ => {}
                })
                .build(app)?;

            Ok(())
        })
        .on_window_event(|window, event| match event {
            WindowEvent::Focused(false) => {
                let _ = window.hide();
            }
            WindowEvent::CloseRequested { api, .. } => {
                api.prevent_close();
                let _ = window.hide();
            }
            _ => {}
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
