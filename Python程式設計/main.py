from kivymd.app import MDApp
from kivy.core.window import Window
from kivy.uix.screenmanager import Screen
from kivy.properties import StringProperty
from kivymd.uix.snackbar import Snackbar
from kivy.uix.label import Label
from kivy.network.urlrequest import UrlRequest
import certifi
import os
from kivymd.uix.bottomsheet import MDListBottomSheet
import requests
import webbrowser
from kivy.lang import Builder




class HomeScreen(Screen):
    pass


class MainApp(MDApp):
    name = StringProperty()
    category = StringProperty()
    area = StringProperty()
    image = StringProperty()
    url = StringProperty()
    youtube = StringProperty()

    def __init__(self,**kwargs):
        Window.size = (1200,1600)
        super().__init__(**kwargs)





    def show_example_list_bottom_sheet(self):
        bs_menu = MDListBottomSheet()
        bs_menu.add_item("Watch",
                         lambda x: self.watch(), icon="youtube", )
        bs_menu.add_item("Code Link",
                         lambda x: self.link(), icon="page-previous", )
        bs_menu.add_item("Made by kerry 407510062",
                         lambda x: None, icon="dev-to", )
        bs_menu.add_item("using Python!", lambda x: self.version(),
                         icon="language-python", )
        bs_menu.add_item("Exit", lambda x: self.Exit(),
                         icon="exit-to-app", )
        bs_menu.open()

    def on_start(self):
        os.environ['SSL_CERT_FILE'] = certifi.where()
        UrlRequest('https://www.themealdb.com/api/json/v1/1/random.php', on_success=self.success, on_failure=self.failure, on_error=self.error)



    def success(self, urlrequest, result):
        ingredient_list = self.root.ids['home'].ids['ingredient_list']
        print(result)
        self.youtube = result['meals'][0]['strYoutube']
        self.name = result['meals'][0]['strMeal']
        self.category = result['meals'][0]['strCategory']
        self.area = result['meals'][0]['strArea']
        self.image = result['meals'][0]['strMealThumb']
        self.url = result['meals'][0]['strSource']
        for i in range(1,21):
            if result['meals'][0][f'strIngredient{i}'] != '':
                l = Label(text=result['meals'][0][f'strIngredient{i}'],color=(0,0,0,1))
                ingredient_list.add_widget(l)



    def error(self, urlrequest):
        print("error")
        Snackbar(text='Url is not available').show()
    def failure(self, urlrequest):
        print("failure")
        Snackbar(text='Url is not available').show()

    def view(self):
        if self.url != '':
            webbrowser.open(self.url)
        if self.url == '':
            Snackbar(text='Url is not available').show()
    def watch(self):
        if self.youtube != '':
            webbrowser.open(self.youtube)
        if self.youtube == '':
            Snackbar(text='Url is not available').show()
    def link(self):
        webbrowser.open('https://github.com/kerry41015104/kerry41015104')
    def goole(self):
        webbrowser.open('https://earth.google.com/web/search/' + self.area)
    def version(self):
        Snackbar(
            text='python version == 3.7'
        ).show()
    def Exit(self):
        exit(0)

MainApp().run()
