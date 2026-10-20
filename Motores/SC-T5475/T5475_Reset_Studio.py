"""Epson SC-T5475 Reset Studio v3.0 - Ejecutable propio @Ricker.
Moderno Win8/10/11: wizard 5 pasos, menus, Acerca de + Info + GitHub.
Repo: https://github.com/ricker72/Epson-Adjustment-Program"""
import os, sys, subprocess, ctypes, webbrowser, tkinter as tk
from tkinter import ttk, messagebox
VER='3.0.0'; AUTOR='@Ricker'; REPO='https://github.com/ricker72/Epson-Adjustment-Program'
BASE=os.path.dirname(os.path.abspath(__file__)) if getattr(sys,'frozen',False) else os.path.dirname(os.path.abspath(__file__))
# cuando es exe, BASE = carpeta del exe (SC-T5475)
if getattr(sys,'frozen',False): BASE=os.path.dirname(sys.executable)
PS1=os.path.join(BASE,'SC-T5475_VidaUtil_Reset.ps1')
DRV='https://epson.com/Support/Printers/Single-Function-Inkjet-Printers/SureColor-Series/Epson-SureColor-T5475/s/SPT_SCT5475SR'
MAN='https://files.support.epson.com/docid/cpd5/cpd58955.pdf'
BG='#0f172a'; CARD='#1e293b'; CARD2='#334155'; ACC='#2f7cf6'; GREEN='#16a34a'; TXT='#f1f5f9'; MUT='#94a3b8'
def admin():
    try: return ctypes.windll.shell32.IsUserAnAdmin()
    except Exception: return False
class App(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title('Epson SC-T5475 Reset Studio v%s | %s' % (VER, AUTOR))
        try: self.iconbitmap(os.path.join(BASE,'Epson_T5475.ico'))
        except Exception: pass
        self.configure(bg=BG); self.geometry('880x620'); self.minsize(840,580)
        s=ttk.Style(self)
        try: s.theme_use('clam')
        except Exception: pass
        s.configure('TFrame',background=BG); s.configure('Card.TFrame',background=CARD)
        s.configure('TLabel',background=BG,foreground=TXT,font=('Segoe UI',10))
        s.configure('Card.TLabel',background=CARD,foreground=TXT)
        s.configure('Mut.TLabel',background=CARD,foreground=MUT,font=('Segoe UI',9))
        s.configure('Title.TLabel',background=BG,foreground='#60a5fa',font=('Segoe UI',22,'bold'))
        s.configure('Sub.TLabel',background=BG,foreground=MUT,font=('Segoe UI',10))
        s.configure('Acc.TButton',background=ACC,foreground='white',font=('Segoe UI',10,'bold'),padding=9)
        s.map('Acc.TButton',background=[('active','#1d4ed8')])
        s.configure('Go.TButton',background=GREEN,foreground='white',font=('Segoe UI',10,'bold'),padding=9)
        s.map('Go.TButton',background=[('active','#15803d')])
        s.configure('TButton',font=('Segoe UI',10),padding=7)
        self.step=tk.IntVar(value=1); self.mc=tk.IntVar(value=-1); self.bl=tk.IntVar(value=-1)
        self.menu(); self.build(); self.check()
    def menu(self):
        m=tk.Menu(self); self.config(menu=m)
        f=tk.Menu(m,tearoff=0); m.add_cascade(label='Archivo',menu=f)
        f.add_command(label='Diagnosticar USB ahora',command=self.check)
        f.add_command(label='Abrir carpeta T5475',command=lambda: os.startfile(BASE))
        f.add_separator(); f.add_command(label='Salir',command=self.destroy)
        h=tk.Menu(m,tearoff=0); m.add_cascade(label='Herramientas',menu=h)
        h.add_command(label='Abrir Drivers oficiales Epson',command=lambda: webbrowser.open(DRV))
        h.add_command(label='Abrir Manual oficial PDF',command=lambda: webbrowser.open(MAN))
        h.add_command(label='Abrir Service Tool T5475',command=self.tool)
        h.add_separator(); h.add_command(label='Ver reporte vida util (JSON)',command=self.rep)
        y=tk.Menu(m,tearoff=0); m.add_cascade(label='Ayuda',menu=y)
        y.add_command(label='Guia rapida',command=self.guia)
        y.add_command(label='Info del programa',command=self.info)
        y.add_separator(); y.add_command(label='Acerca de ...',command=self.about)
    def build(self):
        top=ttk.Frame(self); top.pack(fill='x',padx=22,pady=(14,2))
        ttk.Label(top,text='Epson SC-T5475 Reset Studio',style='Title.TLabel').pack(side='left')
        ttk.Label(top,text='v'+VER,style='Sub.TLabel').pack(side='left',padx=(10,0))
        ttk.Label(top,text=AUTOR,style='Sub.TLabel',font=('Segoe UI',10,'bold')).pack(side='right')
        ttk.Label(self,text='SureColor T5475 / T3475  |  Win 8 / 10 / 11 x64  |  USB-B + SELF-DIAGNOSTIC + Reset a 0',style='Sub.TLabel').pack(anchor='w',padx=22)
        self.prog=ttk.Label(self,text='',style='Sub.TLabel',font=('Segoe UI',11,'bold')); self.prog.pack(pady=(8,0))
        self.card=ttk.Frame(self,style='Card.TFrame',padding=16); self.card.pack(fill='both',expand=True,padx=22,pady=10)
        self.body=ttk.Frame(self.card,style='Card.TFrame'); self.body.pack(fill='both',expand=True)
        nav=ttk.Frame(self); nav.pack(fill='x',padx=22,pady=(0,14))
        ttk.Button(nav,text='Atras',command=self.prev).pack(side='left')
        ttk.Button(nav,text='Diagnosticar',command=self.check).pack(side='left',padx=8)
        self.nx=ttk.Button(nav,text='Siguiente',style='Acc.TButton',command=self.nxt); self.nx.pack(side='right')
        self.show()
    def clear(self):
        for w in self.body.winfo_children(): w.destroy()
    def show(self):
        self.clear(); n=self.step.get()
        self.prog.config(text='PASO %d de 5: %s' % (n,['','Drivers oficiales','USB-B directo','Modo reparacion','Examinar vida util','Reset a 0'][n]))
        [self.p1,self.p2,self.p3,self.p4,self.p5][n-1]()
        self.nx.config(text='Finalizar' if n==5 else 'Siguiente',style='Go.TButton' if n==5 else 'Acc.TButton')
    def hint(self,t):
        ttk.Label(self.body,text=t,style='Mut.TLabel',wraplength=760,justify='left').pack(anchor='w',pady=4)
    def p1(self):
        ttk.Label(self.body,text='1) Instala PRIMERO el driver oficial Epson (sin driver generico no hay reset).',style='Card.TLabel',font=('Segoe UI',11,'bold'),wraplength=760).pack(anchor='w')
        self.hint('Ejemplo: epson.com/Support > T5475 > Drivers > Printer Driver > USB Directo. Si tu cola dice Generic/IPP Class, reinstala.')
        ttk.Button(self.body,text='Abrir pagina oficial de drivers',command=lambda: webbrowser.open(DRV)).pack(fill='x',pady=6)
        self.st1=ttk.Label(self.body,text='',style='Mut.TLabel'); self.st1.pack(anchor='w')
    def p2(self):
        ttk.Label(self.body,text='2) Conecta USB-B <2m a puerto trasero 2.0, sin hub. Cola en USB00x (no WSD).',style='Card.TLabel',font=('Segoe UI',11,'bold'),wraplength=760).pack(anchor='w')
        self.hint('Enciende plotter, verifica VID_04B8. Comando: Get-Printer | Format-Table Name,PortName')
        ttk.Button(self.body,text='Verificar USB ahora',command=self.check).pack(anchor='w',pady=6)
        self.st2=ttk.Label(self.body,text='',style='Mut.TLabel'); self.st2.pack(anchor='w')
    def p3(self):
        ttk.Label(self.body,text='3) Pon modo SELF-DIAGNOSTIC: apaga, manten OK + Menu y enciende 5 seg.',style='Card.TLabel',font=('Segoe UI',11,'bold'),wraplength=760).pack(anchor='w')
        self.hint('Panel debe decir SELF-DIAGNOSTIC / SERVICE MODE. Sin este modo el tool da Communication error. Errores 00000008/00080000 = Maintenance/Borderless lleno.')
        ttk.Button(self.body,text='Abrir manual oficial PDF',command=lambda: webbrowser.open(MAN)).pack(fill='x',pady=6)
    def p4(self):
        ttk.Label(self.body,text='4) Cuanto le queda? Marca aproximado del panel.',style='Card.TLabel',font=('Segoe UI',11,'bold')).pack(anchor='w')
        f=ttk.Frame(self.body,style='Card.TFrame'); f.pack(fill='x',pady=6)
        ttk.Label(f,text='Maintenance T582000 %:',style='Card.TLabel').pack(side='left')
        ttk.Scale(f,from_=0,to=100,variable=self.mc,orient='horizontal',length=300).pack(side='left',padx=8)
        ttk.Label(f,textvariable=self.mc,style='Card.TLabel').pack(side='left')
        f2=ttk.Frame(self.body,style='Card.TFrame'); f2.pack(fill='x',pady=6)
        ttk.Label(f2,text='Borderless / spit %:',style='Card.TLabel').pack(side='left')
        ttk.Scale(f2,from_=0,to=100,variable=self.mc if False else self.bl,orient='horizontal',length=300).pack(side='left',padx=8)
        ttk.Label(f2,textvariable=self.bl,style='Card.TLabel').pack(side='left')
        self.hint('Mayor 90% = cambia T582000 pronto. 100% = bloqueo activo, no imprimas hasta reset.')
        ttk.Button(self.body,text='Guardar lectura',command=self.save).pack(anchor='w',pady=6)
    def p5(self):
        ttk.Label(self.body,text='5) Cambia T582000 nuevo + SELF-DIAGNOSTIC + USB, luego RESET A 0.',style='Card.TLabel',font=('Segoe UI',11,'bold'),wraplength=760).pack(anchor='w')
        self.hint('Seguridad: reset sin cartucho nuevo = derrame. Si hay Service Tool lo abro en SC-T5475 > Particular > Maintenance > Check > Initialize > Finish. Si no, hago reset logico local JSON + guia fisico. Apaga 15 seg > enciende > sin 00000008.')
        ttk.Button(self.body,text='RESET A 0 (pide doble confirmacion)',style='Go.TButton',command=self.reset).pack(fill='x',pady=8)
        ttk.Button(self.body,text='Abrir Service Tool T5475',command=self.tool).pack(fill='x',pady=4)
    def prev(self):
        if self.step.get()>1: self.step.set(self.step.get()-1); self.show()
    def nxt(self):
        if self.step.get()<5: self.step.set(self.step.get()+1); self.show()
        else: messagebox.showinfo('Listo','Si tu reporte dice 0% y el plotter esta READY sin 00000008, ya quedo. Guarda el JSON.')
    def usbq(self):
        try:
            o=subprocess.run(['powershell','-NoProfile','-Command',"Get-Printer | Where-Object {$_.Name -match 'T5475|SC-T|SureColor'} | Select-Object Name,PortName,DriverName | ConvertTo-Json"],capture_output=True,text=True,timeout=20)
            return o.stdout.strip()
        except Exception as e: return str(e)
    def check(self):
        t=self.usbq()
        msg='Epson USB: revisa VID_04B8 en Administrador de dispositivos.\nColas T5475:\n'+(t or 'sin cola')
        try: self.st1.config(text=msg[:400])
        except Exception: pass
        try: self.st2.config(text=msg[:400])
        except Exception: pass
        messagebox.showinfo('Diagnostico USB',msg[:800])
    def save(self):
        import json
        d=os.path.join(BASE,'Reportes'); os.makedirs(d,exist_ok=True)
        j=os.path.join(d,'SC-T5475_vida_util.json')
        rec={'modelo':'SC-T5475','tool':VER,'maintenance_cart_pct':int(self.mc.get()),'borderless_pct':int(self.bl.get())}
        open(j,'w',encoding='utf-8').write(json.dumps(rec,indent=2))
        messagebox.showinfo('OK','Lectura guardada en Reportes\\SC-T5475_vida_util.json')
    def tool(self):
        import glob
        cands=glob.glob(os.path.join(BASE,'*.exe'))
        cands=[c for c in cands if os.path.basename(c).lower() not in ('t5475_reset_studio.exe',)]
        if not cands:
            messagebox.showinfo('SC-T5475','Copia tu AdjProg_SC-T5475.exe aqui junto a apdadrv.dll + StrGene.dll. El reset logico + guia ya funcionan sin el.')
            try: os.startfile(BASE)
            except Exception: pass
            return
        if not admin():
            ctypes.windll.shell32.ShellExecuteW(None,'runas',cands[0],None,None,1); return
        subprocess.Popen([cands[0]],cwd=BASE)
    def rep(self):
        p=os.path.join(BASE,'Reportes','SC-T5475_vida_util.json')
        if os.path.exists(p):
            try: os.startfile(p)
            except Exception: pass
        else: messagebox.showinfo('Reporte','Aun no hay reporte. Guarda lectura en paso 4 o haz reset en paso 5.')
    def guia(self):
        for f in ['Guia_T5475_PROFESIONAL.md','Guia_Epson_SureColor_T5475_Paso_a_Paso.txt','MANUAL_SC-T5475_VidaUtil_Reset.txt']:
            p=os.path.join(BASE,f)
            if os.path.exists(p):
                try: os.startfile(p); return
                except Exception: pass
        messagebox.showinfo('Guia','Drivers > USB-B > SELF-DIAGNOSTIC > vida util > cambia T582000 > reset 0 > apaga 15 seg.')
    def reset(self):
        import json
        if messagebox.askyesno('1/2','Cambiaste el Maintenance T582000 por uno NUEVO? Sin cartucho nuevo hay derrame.')!=True: return
        if messagebox.askyesno('2/2','Estas en SELF-DIAGNOSTIC + USB + driver OK?')!=True: return
        self.tool()
        import tkinter.simpledialog as sd
        r=sd.askstring('Confirmar','Escribe RESET0 para poner a 0:',parent=self)
        if r!='RESET0': messagebox.showinfo('Cancelado','No se hizo reset.'); return
        d=os.path.join(BASE,'Reportes'); os.makedirs(d,exist_ok=True)
        j=os.path.join(d,'SC-T5475_vida_util.json')
        prev={}
        try: prev=json.loads(open(j,encoding='utf-8').read())
        except Exception: pass
        rec={'modelo':'SC-T5475','tool':VER,'maintenance_cart_pct':0,'borderless_pct':0,'previo_mc':prev.get('maintenance_cart_pct'),'previo_bl':prev.get('borderless_pct'),'manual':MAN}
        open(j,'w',encoding='utf-8').write(json.dumps(rec,indent=2))
        messagebox.showinfo('Puesto a 0','Reporte en 0. Apaga 15 seg > enciende > verifica READY sin 00000008.')
    def info(self):
        w=tk.Toplevel(self); w.title('Info - T5475 Reset Studio'); w.configure(bg=CARD); w.geometry('560x480')
        t=tk.Text(w,bg=CARD,fg=TXT,relief='flat',font=('Segoe UI',10),wrap='word',padx=14,pady=12)
        t.pack(fill='both',expand=True)
        t.insert('end','INFO DEL PROGRAMA\nEpson SC-T5475 Reset Studio v%s\nParche / Studio por %s\n\nQUE HACE:\n- Guia drivers oficiales Epson T5475 (SPT_SCT5475SR)\n- Verifica USB-B VID_04B8 + cola en USB00x\n- Guia modo SELF-DIAGNOSTIC / SERVICE MODE\n- Examina vida util Maintenance T582000 + Borderless\n- Reset logico a 0 + abre Service Tool T-Series si existe\n- Manual oficial cpd58955 integrado\n\nCOMPATIBLE:\nWindows 8 / 8.1 / 10 / 11 x64. Requiere admin para USB.\nModelos: SC-T5475 (SCT5475SR), T3475, T5470.\nErrores: 00000008 / 00080000.\n\nREPOSITORIO:\n%s\nReporta issues con modelo + Windows + foto error.\n\nCREDITOS:\nCreador del parche: %s. Basado en Adjustment Program Epson.\nEste studio no borra nada solo: pide doble confirmacion + RESET0.\n' % (VER,AUTOR,REPO,AUTOR))
        t.config(state='disabled')
        ttk.Button(w,text='Abrir repositorio en GitHub',command=lambda: webbrowser.open(REPO)).pack(pady=8)
    def about(self):
        messagebox.showinfo('Acerca de','Epson SC-T5475 Reset Studio v%s\n\nCreador del parche: %s\nRepositorio:\n%s\n\nDiseno moderno Win 8/10/11.\nIcono propio T5475.\nTodo lo T5475 vive en Motores\\SC-T5475\\, separado de L.' % (VER,AUTOR,REPO))
if __name__=='__main__':
    App().mainloop()




