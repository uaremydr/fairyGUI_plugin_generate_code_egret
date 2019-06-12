1.如果需要打印日志，在“文件”——“项目设置”——“自定义属性”中设置key:logPath,value:*日志路径即可；
2.在“文件”——“项目设置”——“自定义属性”中设置key:egretCode,value:true属性才能使用此插件；
3.在“文件”——“项目设置”——“自定义属性”中设置key:loadType,value:*属性可设置生成代码类型
	value == 1:在编辑器中名称后加@，@之后的路径将作为发布后该组件对应的引用类型，比如：名称为btn_get@fairui.EButton，生成代码中 public btn_get:fairui.EButton.
	value == 2:此时需要在“文件”——“项目设置”——“自定义属性”中设置key:importPackageName,value:*属性，value属性将对应发布后所有非Fairygui自带组件的引用类型包名，比如:
			   value == fairui:当面板中使用了自己写的组件ItemView,名称为item,生成代码中 public item:fairui.ItemView.
4.在“文件”——“项目设置”——“自定义属性”中设置key:exSuperClass,value:*属性可更换编辑器默认继承的父类,比如：
	默认生成的类export class UI_TeamView extends fairygui.GComponent
	设置value : {"GComponent":"fairui.BaseSprite"}， 生成的类为export class UI_TeamView extends fairui.BaseSprite，
	这样做的好处是，将BaseSprite类继承fairygui.GComponent，就可以在BaseSprite中扩展一些通用方法，便于面板统一处理；
注意事项：
	1.“文件”——“发布设置”中不需要点击“生成代码：为本包生成代码”项，如果点击，生成的代码将被UI编辑器生成的代码所覆盖。
	2.“文件”——“发布设置”——“编辑全局设置”中“代码发布设置”依然有效，所以必须在此处设置“代码保存路径”和“包名称”；