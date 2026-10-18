"""AdjProg Modern Launcher v2.0.0 - Win8/10/11 + x64. Panel moderno estable."""
import os, sys, subprocess, ctypes, tkinter as tk
from tkinter import ttk, messagebox
BASE = os.path.dirname(os.path.abspath(__file__))
EXE_PAR = os.path.join(BASE, 'AdjProg_Win10_x64ready.exe')
EXE_ORI = os.path.join(BASE, 'AdjProg.exe')
MANIFEST = os.path.join(BASE, 'AdjProg.exe.manifest')
BG='#1e2126'; CARD='#262b33'; ACC='#2f7cf6'; TXT='#e8ecf1'; MUT='#9aa3b2'
def exe_target():
    return EXE_PAR if os.path.exists(EXE_PAR) else EXE_ORI
def is_admin():
    try: return ctypes.windll.shell32.IsUserAnAdmin()
    except Exception: return False
class App(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title('EPSON Adjustment Program  v2.0.0 | Win 11 ready | @Ricker')
        self.configure(bg=BG)
        self.geometry('860x560'); self.minsize(820, 520)
        s = ttk.Style(self)
        try: s.theme_use('clam')
        except Exception: pass
        s.configure('TFrame', background=BG)
        s.configure('Card.TFrame', background=CARD)
        s.configure('TLabel', background=BG, foreground=TXT, font=('Segoe UI', 10))
        s.configure('Card.TLabel', background=CARD, foreground=TXT)
        s.configure('Title.TLabel', background=BG, foreground='#3b82f6', font=('Segoe UI', 22, 'bold'))
        s.configure('Sub.TLabel', background=BG, foreground=MUT, font=('Segoe UI', 10))
        s.configure('Acc.TButton', background=ACC, foreground='white', font=('Segoe UI', 10, 'bold'), padding=10)
        s.map('Acc.TButton', background=[('active', '#1f6feb')])
        s.configure('TButton', font=('Segoe UI', 10), padding=8)
        self._build(); self.refresh()
    def _build(self):
        top = ttk.Frame(self); top.pack(fill='x', padx=24, pady=(18, 6))
        ttk.Label(top, text='EPSON Adjustment Program', style='Title.TLabel').pack(side='left')
        ttk.Label(top, text='v2.0.0', style='Sub.TLabel').pack(side='left', padx=(10, 0))
        ttk.Label(self, text='L1210 L3210 L3250 L3251 L3260 L5290 | Win 8/10/11 x64 (WOW64) | @Ricker', style='Sub.TLabel').pack(anchor='w', padx=24)
        mid = ttk.Frame(self); mid.pack(fill='both', expand=True, padx=24, pady=10)
        mid.columnconfigure(0, weight=1); mid.columnconfigure(1, weight=1)
        left = ttk.Frame(mid, style='Card.TFrame', padding=16)
        left.grid(row=0, column=0, sticky='nsew', padx=(0, 8))
        ttk.Label(left, text='Modos de ajuste', style='Card.TLabel', font=('Segoe UI', 12, 'bold')).pack(anchor='w')
        ttk.Label(left, wraplength=360, style='Card.TLabel', text='Modos de ajuste para mantenimiento del dispositivo. Siga el orden correcto tras seleccionar piezas de repuesto o reparadas. Multi-seleccion posible. Win 11 Por @Ricker').pack(anchor='w', pady=(8, 12))
        ttk.Button(left, text='Iniciar modo secuencial (recomendado)', style='Acc.TButton', command=self.launch).pack(fill='x', pady=4)
        ttk.Button(left, text='Abrir AdjProg (motor original)', command=self.launch).pack(fill='x', pady=4)
        ttk.Button(left, text='Salir', command=self.destroy).pack(fill='x', pady=4)
        right = ttk.Frame(mid, style='Card.TFrame', padding=16)
        right.grid(row=0, column=1, sticky='nsew', padx=(8, 0))
        ttk.Label(right, text='Estado del sistema', style='Card.TLabel', font=('Segoe UI', 12, 'bold')).pack(anchor='w')
        self.st = tk.Text(right, height=12, bg='#1b1f25', fg=TXT, insertbackground=TXT, relief='flat', font=('Consolas', 9), wrap='word')
        self.st.pack(fill='both', expand=True, pady=(8, 12))
        row = ttk.Frame(right, style='Card.TFrame'); row.pack(fill='x')
        ttk.Button(row, text='Diagnosticar', command=self.refresh).pack(side='left')
        ttk.Button(row, text='Aplicar compat', command=self.compat).pack(side='left', padx=6)
        ttk.Button(row, text='Ayuda', command=self.help).pack(side='right')
        self.bar = ttk.Label(self, text='', style='Sub.TLabel'); self.bar.pack(anchor='w', padx=24, pady=(0, 14))
    def log(self, m):
        self.st.insert('end', m + '\n'); self.st.see('end')
    def refresh(self):
        self.st.delete('1.0', 'end')
        t = exe_target()
        self.log('EXE: %s (%d bytes)' % (os.path.basename(t), os.path.getsize(t)))
        self.log('Admin: %s' % ('SI' if is_admin() else 'NO (se pedira)'))
        self.log('Windows: %s' % ('x64 (WOW64)' if 'ProgramFiles(x86)' in os.environ else 'x86'))
        for f in ['apdadrv.dll', 'StrGene.dll']:
            self.log('%s: %s' % (f, 'OK' if os.path.exists(os.path.join(BASE, f)) else 'FALTA'))
        try:
            d = open(t, 'rb').read()
            self.log('Texto Opcion B: %s' % ('OK' if b'Modos de ajuste' in d else 'no'))
            self.log('Version 2.0.0: %s' % ('OK' if d.count(b'2.0.0') >= 4 else 'revisar'))
        except Exception as e: self.log(str(e))
        self.log('Conecte impresora por USB 2.0 ANTES de elegir modelo.')
        self.bar.config(text='Listo | %s | v2.0.0' % os.path.basename(t))
    def compat(self):
        t = exe_target()
        try:
            import winreg
            k = winreg.CreateKey(winreg.HKEY_CURRENT_USER, r'Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers')
            winreg.SetValueEx(k, t, 0, winreg.REG_SZ, 'WIN7RTM HIGHDPIAWARE RUNASADMIN DISABLEDXMAXIMIZEDWINDOWEDMODE DISABLEFULLSCREENOPTIMIZATIONS DPIUNAWARE')
            winreg.CloseKey(k)
            messagebox.showinfo('OK', 'Compatibilidad aplicada.')
        except Exception as e: messagebox.showerror('Error', str(e))
        self.refresh()
    def launch(self):
        t = exe_target()
        if not is_admin():
            self.log('Pidiendo admin...')
            ctypes.windll.shell32.ShellExecuteW(None, 'runas', sys.executable, '"%s" --x' % os.path.abspath(__file__), None, 1)
            return
        try:
            import winreg
            k = winreg.CreateKey(winreg.HKEY_CURRENT_USER, r'Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers')
            winreg.SetValueEx(k, t, 0, winreg.REG_SZ, 'WIN7RTM HIGHDPIAWARE RUNASADMIN DISABLEDXMAXIMIZEDWINDOWEDMODE DISABLEFULLSCREENOPTIMIZATIONS DPIUNAWARE')
            winreg.CloseKey(k)
        except Exception: pass
        self.log('Lanzando %s ...' % os.path.basename(t))
        subprocess.Popen([t], cwd=BASE)
    def help(self):
        messagebox.showinfo('Ayuda', '1. USB 2.0 conectado.\n2. Boton azul (pide admin).\n3. Select > modelo > Particular adjustment mode.\n\nEl motor MFC original (139 dialogos) se mantiene intacto por estabilidad.')
if __name__ == '__main__':
    App().mainloop()

