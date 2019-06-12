package{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.describeType;
	
	import fairygui.editor.plugin.ICallback;
	import fairygui.editor.plugin.IEditorUIProject;
	import fairygui.editor.plugin.IFairyGUIEditor;
	import fairygui.editor.plugin.IPublishData;
	import fairygui.editor.plugin.IPublishHandler;
	
	public final class AutoGenerateNewCodePlugin implements IPublishHandler{
		/**发布数据*/
		private var _publishData:IPublishData;
		/**返回接口*/
		private var _callback:ICallback;
		
		/**编辑器信息（FairyGUI-Editor下的信息）*/
		private var _editor:IFairyGUIEditor;
		/**当前UI项目所有信息*/
		private var _project:IEditorUIProject;
		/**当前UI项目下settings文件夹下文件,
		 * 例如：commom,workspace,adaptation,publish,customProps(此属性也可从IEditorUIProject.customProperties获取)
		 * */
		private var _projectSettingsCenter:Object;
		/**当前UI项目下settings文件夹下Publish.json*/
		private var _projectPublishSettings:Object;
		/**用户自定义属性*/
		private var _customProperties:Object;
		
		/**日志发布路径*/
		private var _logPath:String = "";
		/**加载方法*/
		private var _loadType:String = "1";
		/**成员导入包名*/
		private var _importPackageName:String = "";
		/**需要修改的父类*/
		private var _exSuperClass:Object;
		
		/**代码发布路径*/
		private var _codePath:String = "";
		/**组件名前缀*/
		private var _cNamePrefix:String = "";
		/**成员名称前缀*/
		private var _mNamePrefix:String = "";
		/**模块导入包名*/
		private var _modulePackageName:String = "";
		
		/**加载类型*/
		private var _loadTypeArr:Array = ["1", "2"];
		
		public function AutoGenerateNewCodePlugin(editor:IFairyGUIEditor){
			_editor = editor;
		}
		/**清理数据*/
		private function clearData():void{
			_publishData = null;
			_callback = null;
			_project = null;
			_projectSettingsCenter = null;
			_projectPublishSettings = null;
			_customProperties = null;
			_logPath = "";
			_loadType = "1";
			_importPackageName = "";
			_exSuperClass = null;
			_codePath = "";
			_cNamePrefix = "";
			_mNamePrefix = "";
			_modulePackageName = "";
		}
		
		/**初始化数据*/
		private function initData(data:IPublishData, callback:ICallback):void{
			clearData();
			_publishData = data;
			_callback = callback;
			_project = _editor.project;
			if(_project["settingsCenter"]){
				_projectSettingsCenter = _project["settingsCenter"];
				if(_projectSettingsCenter["publish"]){
					_projectPublishSettings = _projectSettingsCenter.publish;
					
					if(_projectPublishSettings["codePath"]){
						_codePath = _projectPublishSettings.codePath;
					}
					if(_projectPublishSettings["classNamePrefix"]){
						_cNamePrefix = _projectPublishSettings.classNamePrefix;
					}
					if(_projectPublishSettings["memberNamePrefix"]){
						_mNamePrefix = _projectPublishSettings.memberNamePrefix;
					}
					if(_projectPublishSettings["packageName"]){
						_modulePackageName = _projectPublishSettings.packageName;
					}
				}
			}
			_customProperties = _project.customProperties;
			if(_customProperties["logPath"]){
				_logPath = _customProperties["logPath"];
				clearLogFile();
			}
			if(_customProperties["loadType"] && _loadTypeArr.indexOf(_customProperties["loadType"]) != -1){
				_loadType = _customProperties["loadType"];
			}
			if(_customProperties["importPackageName"]){
				_importPackageName = _customProperties["importPackageName"] + ".";
			}
			if(_customProperties["exSuperClass"]){
				_exSuperClass = JSON.parse(_customProperties["exSuperClass"]);
			}
			
//			logXMLByObject(_editor, "editor");
			
//			logXMLByObject(_project, "project");
			printLog("当前项目(_project) globalFontVersion:" + _project["globalFontVersion"]);
			printLog("当前项目(_project) opened:" + _project["opened"]);
			printLog("当前项目(_project) supportExtraAlpha:" + _project["supportExtraAlpha"]);
			printLog("当前项目(_project) supportAtlas:" + _project["supportAtlas"]);
			printLog("当前项目(_project) supportAlphaMask:" + _project["supportAlphaMask"]);
			printLog("当前项目(_project) isH5:" + _project["isH5"]);
			printLog("当前项目(_project) zipFormatOption:" + _project["zipFormatOption"]);
			printLog("当前项目(_project) binaryFormatOption:" + _project["binaryFormatOption"]);
			printLog("当前项目(_project) supportCustomFileExtension:" + _project["supportCustomFileExtension"]);
			printLog("当前项目(_project) supportCodeType:" + _project["supportCodeType"]);
			printLog("当前项目(_project) assetsPath:" + _project["assetsPath"]);
			printLog("当前项目(_project) objsPath:" + _project["objsPath"]);
			printLog("当前项目(_project) settingsPath:" + _project["settingsPath"]);
			printLog("当前项目(_project) name:" + _project.name);
			printLog("当前项目(_project) id:" + _project.id);
			printLog("当前项目(_project) basePath:" + _project.basePath);
			printLog("当前项目(_project) type:" + _project.type);
			printLog("当前项目(_project) packageCount:" + _project["packageCount"]);
			
//			logXMLByObject(_project["editorWindow"], "editorWindow");
			
//			logXMLByObject(_project["settingsCenter"], "settingsCenter");
			
//			logXMLByObject(_projectPublishSettings, "projectPublishSettings");
			printLog("当前项目发布设置(_projectPublishSettings) compressDesc:" + _projectPublishSettings["compressDesc"]);
			printLog("当前项目发布设置(_projectPublishSettings) fileExtension:" + _projectPublishSettings["fileExtension"]);
			printLog("当前项目发布设置(_projectPublishSettings) codePath:" + _projectPublishSettings["codePath"]);
			printLog("当前项目发布设置(_projectPublishSettings) unityDataFormat:" + _projectPublishSettings["unityDataFormat"]);
			printLog("当前项目发布设置(_projectPublishSettings) memberNamePrefix:" + _projectPublishSettings["memberNamePrefix"]);
			printLog("当前项目发布设置(_projectPublishSettings) packageName:" + _projectPublishSettings["packageName"]);
			printLog("当前项目发布设置(_projectPublishSettings) packageCount:" + _projectPublishSettings["packageCount"]);
			printLog("当前项目发布设置(_projectPublishSettings) getMemberByName:" + _projectPublishSettings["getMemberByName"]);
			printLog("当前项目发布设置(_projectPublishSettings) classNamePrefix:" + _projectPublishSettings["classNamePrefix"]);
			printLog("当前项目发布设置(_projectPublishSettings) ignoreNoname:" + _projectPublishSettings["ignoreNoname"]);
			printLog("当前项目发布设置(_projectPublishSettings) binaryFormat:" + _projectPublishSettings["binaryFormat"]);
			printLog("当前项目发布设置(_projectPublishSettings) codeType:" + _projectPublishSettings["codeType"]);
			printLog("当前项目发布设置(_projectPublishSettings) filePath:" + _projectPublishSettings["filePath"]);
			
//			logXMLByObject(_publishData, "IPublishData");
			printLog("发布数据(_publishData) _defaultPrevented:" + _publishData["_defaultPrevented"]);
			printLog("发布数据(_publishData) usingAtlas:" + _publishData["usingAtlas"]);
			printLog("发布数据(_publishData) _exportDescOnly:" + _publishData.exportDescOnly);
			printLog("发布数据(_publishData) _filePath:" + _publishData.filePath);
			printLog("发布数据(_publishData) _fileName:" + _publishData.fileName);
			printLog("发布数据(_publishData) _fileExtension:" + _publishData.fileExtention);
			printLog("发布数据(_publishData) _singlePackage:" + _publishData.singlePackage);
			printLog("发布数据(_publishData) _extractAlpha:" + _publishData.extractAlpha);
			printLog("发布数据(_publishData) _genCode:" + _publishData["_genCode"]);
			printLogObject("发布数据(_publishData) _outputClasses:", _publishData["_outputClasses"]);
			
//			logXMLByObject(_publishData.targetUIPackage, "IEditorUIPackage");
		}
		
		/**
		 * 组件输出类定义列表。这是一个Map，key是组件id，value是一个结构体，例如：
		 * {
		 * 		classId : "8swdiu8f",
		 * 		className ： "AComponent",
		 * 		superClassName : "GButton",
		 * 		members : [
		 * 			{ name : "n1" : type : "GImage" },
		 * 			{ name : "list" : type : "GList" },
		 * 			{ name : "a1" : type : "GComponent", src : "Component1" },
		 * 			{ name : "a2" : type : "GComponent", src : "Component2", pkg : "Package2" },
		 * 		]
		 * }
		 * 注意member里的name并没有做排重处理。
		 */
		public function doExport(data:IPublishData, callback:ICallback):Boolean{
			initData(data, callback);
			if(_customProperties["egretCode"] != "true"){
				return false;
			}
			printLog("初始化插件数据完成，开始运行插件");	
			
			if (_codePath == "" || _codePath == null){
				printLog("没有设置代码保存路径;");
				callback.addMsg("没有设置代码保存路径");
				callback.callOnFail();
				return false;
			}else{
				printLog("代码保存路径:" + _codePath);
			}
			
			//获取配置中代码保存路径
			var code_path:String = new File(_publishData.filePath).resolvePath(_codePath).nativePath;
			
			var codeFolder:File = new File(_publishData.filePath);
			//包名
			var bindPackage:String = PinYinUtils.toPinyin(_publishData.targetUIPackage.name);
			codeFolder = codeFolder.resolvePath(code_path + File.separator + getFilePackage(bindPackage));//根据不同包生成不同的代码文件夹
			
			printLog("代码路径:" + codeFolder.nativePath);
			try{
				if(codeFolder.exists){
					codeFolder.deleteDirectory(true);
				}
			} 
			catch(error:Error){
				printLog("删除原有文件失败:" + codeFolder.nativePath + "目标文件夹不存在");
			}
			if(!codeFolder.exists)
				codeFolder.createDirectory();
			
			if(_modulePackageName == "" || _modulePackageName == null){
				printLog("没有设置包名，如果不设置，将导致所有类全部导入。在“文件”-“发布设置”-“编辑全局设置”中设置包名称。");
				callback.addMsg("没有设置module路径，如果不设置，将导致所有类全部导入。");
				callback.callOnFail();
				return false;
			}
			
			var classCodes:Array = [];
			var bindCodes:Array = [];
			var className:String = "";
			
			printLog("开始生成代码文件");
			var binderName:String = bindPackage + "Binder";
			printLogAndSave(bindCodes, "module " + _modulePackageName + "." + bindPackage + "{");
			printLogAndSave(bindCodes, "\timport UIObjectFactory = fairygui.UIObjectFactory;");
			printLogAndSave(bindCodes, "");
			printLogAndSave(bindCodes, "\texport class " + binderName + "{");
			printLogAndSave(bindCodes, "\t\tpublic static bindAll():void{");
			for each(var bInfo:Object in _publishData.outputClasses){
				className = _cNamePrefix + PinYinUtils.toPinyin(bInfo.className); //你也可以加个前缀后缀啥的
				printLogAndSave(bindCodes, "\t\t\tUIObjectFactory.setPackageItemExtension(" + className + ".URL, " + _importPackageName + bindPackage + "." + PinYinUtils.toPinyin(bInfo.className) + ");");
			}
			printLogAndSave(bindCodes, "\t\t}");
			printLogAndSave(bindCodes, "\t}");
			printLogAndSave(bindCodes, "}");
			
			FileTool.writeFile(codeFolder.nativePath + File.separator + binderName + ".ts", bindCodes.join("\r\n"));
			
			var sameBindImportCheck:Object = {};
			
			for each(var cInfo:Object in _publishData.outputClasses)
			{
				classCodes.length = 0;
				
				className = _cNamePrefix + PinYinUtils.toPinyin(cInfo.className); //你也可以加个前缀后缀啥的
				printLogAndSave(classCodes, "module " + _modulePackageName + "." + bindPackage + "{");
				printLogAndSave(classCodes, "")
				
				if(_exSuperClass && _exSuperClass[cInfo.superClassName]){
					printLogAndSave(classCodes, "\texport class " + className + " extends " + _exSuperClass[cInfo.superClassName] + "{");
				}else{
					printLogAndSave(classCodes, "\texport class " + className + " extends fairygui." + cInfo.superClassName + "{");
				}
				
				printLogAndSave(classCodes, "\t\tpublic static URL:string = " + "\"ui://" + _publishData.targetUIPackage.id + cInfo.classId + "\";");
				printLogAndSave(classCodes, "");
				var memberImportSameCheck:Object = {};
				
				for each(var mInfo:Object in cInfo.members)
				{
					if (!_projectPublishSettings["ignoreNoname"] || !checkIsUseDefaultName(mInfo.name)){
						if(mInfo.src){
							var uiPkg:Object = null;
							if(mInfo.pkg){
								uiPkg = _editor.getPackage(mInfo.pkg);
							}else{
								uiPkg = _publishData.targetUIPackage;
							}
							var itemObj:Object = uiPkg.getItemByName.apply(uiPkg, [mInfo.src]);
							if(itemObj && itemObj.path && itemObj.fileName){
								var projectXML:XML = new XML(FileTool.readFile(uiPkg.basePath + itemObj.path + itemObj.fileName));
								if(projectXML && projectXML.attribute("extention").toXMLString()){
//									printLog(mInfo.src + ":" + projectXML.attribute("extention").toXMLString());
									mInfo.type = "G" + projectXML.@extention;
								}
							}
						}
						
						/**
						 *	type:GComponent	组件类型（必然存在）
						 *	name:btn_buy	组件名字
						 *	pkg_id:q4evlwcj	包id（跨包使用是存在）
						 *	pkg:common	包名（跨包使用时存在）
						 *	src_id:dzdz5e	路径id（使用组件时存在）
						 *	src:EButton	路径名（使用组件时存在）
						 *	index:1	下标
						 */
						if(_loadType == "1"){
							//方法一：通过@符号链接需要加载的类名
							if (mInfo.name){
								var nameArr:Array = (mInfo.name as String).split("@");
								if(nameArr.length > 1){
									printLogAndSave(classCodes, "\t\tpublic " + _mNamePrefix + PinYinUtils.toPinyin(nameArr[0]) + ":" + nameArr[1] + ";");
								}else{
									printLogAndSave(classCodes, "\t\tpublic " + _mNamePrefix + PinYinUtils.toPinyin(mInfo.name) + ":fairygui." + PinYinUtils.toPinyin(mInfo.type) + ";");
								}
							}
						}else if(_loadType == "2"){
							//方法二：通过成员的参数，直接加载类名
							if (mInfo.name){
								if(mInfo.src){
									if(mInfo.pkg){
										printLogAndSave(classCodes, "\t\tpublic " + _mNamePrefix + PinYinUtils.toPinyin(mInfo.name) + ":" + _importPackageName + mInfo.pkg + "." + mInfo.src + ";");
									}else{
										printLogAndSave(classCodes, "\t\tpublic " + _mNamePrefix + PinYinUtils.toPinyin(mInfo.name) + ":" + _importPackageName + bindPackage + "." + mInfo.src + ";");
									}
								}else{
									printLogAndSave(classCodes, "\t\tpublic " + _mNamePrefix + PinYinUtils.toPinyin(mInfo.name) + ":fairygui." + PinYinUtils.toPinyin(mInfo.type) + ";");
								}
							}
						}
					}
				}
				
				printLogAndSave(classCodes, "");
				printLogAndSave(classCodes, "\t\tpublic static createInstance():" + _importPackageName + bindPackage + "." + PinYinUtils.toPinyin(cInfo.className) + "{");
				printLogAndSave(classCodes, "\t\t\treturn <" + _importPackageName + bindPackage + "." + PinYinUtils.toPinyin(cInfo.className) + "><any>(fairygui.UIPackage.createObject(\"" + PinYinUtils.toPinyin(_publishData.targetUIPackage.name) + "\",\"" + cInfo.className + "\"));");
				printLogAndSave(classCodes, "\t\t}");
				
				printLogAndSave(classCodes, "");
				printLogAndSave(classCodes, "\t\tpublic constructor(){");
				printLogAndSave(classCodes, "\t\t\tsuper();");
				printLogAndSave(classCodes, "\t\t}");
				
				printLogAndSave(classCodes, "");
				printLogAndSave(classCodes, "\t\tprotected constructFromXML(xml:any):void{");
				printLogAndSave(classCodes, "\t\t\tsuper.constructFromXML(xml);");
				printLogAndSave(classCodes, "");
				
				
				var childIndex:int = 0;
				var controllerIndex:int = 0;
				var transitionIndex:int = 0;
				for each(mInfo in cInfo.members){
					if(mInfo.type=="Controller"){
						if (!_projectPublishSettings["ignoreNoname"] || !checkIsUseDefaultName(mInfo.name)){
							if (_projectPublishSettings["getMemberByName"]) {
								printLogAndSave(classCodes, "\t\t\tthis." + _mNamePrefix + PinYinUtils.toPinyin(mInfo.name) + " = this.getController(\"" + mInfo.name + "\");");
							}else{
								printLogAndSave(classCodes, "\t\t\tthis." + _mNamePrefix + PinYinUtils.toPinyin(mInfo.name) + " = this.getControllerAt(" + controllerIndex + ");");
							}
						}
						controllerIndex++;
					}else if(mInfo.type=="Transition"){
						if (!_projectPublishSettings["ignoreNoname"] || !checkIsUseDefaultName(mInfo.name)){
							if (_projectPublishSettings["getMemberByName"]) {
								printLogAndSave(classCodes, "\t\t\tthis." + _mNamePrefix + PinYinUtils.toPinyin(mInfo.name) + " = this.getTransition(\"" + mInfo.name + "\");");
							}else{
								printLogAndSave(classCodes, "\t\t\tthis." + _mNamePrefix + PinYinUtils.toPinyin(mInfo.name) + " = this.getTransitionAt(" + transitionIndex + ");");
							}
						}
						transitionIndex++;
					}else{
						if (!_projectPublishSettings["ignoreNoname"] || !checkIsUseDefaultName(mInfo.name)){
							if(_loadType == "1"){
								//方法一：通过@符号链接需要加载的类名
								if (mInfo.name){
									var nameArr1:Array = (mInfo.name as String).split("@");
									if(nameArr1.length > 1){
										if (_projectPublishSettings["getMemberByName"]) {
											printLogAndSave(classCodes, "\t\t\tthis." + _mNamePrefix + PinYinUtils.toPinyin(nameArr1[0]) + " = <" + nameArr1[1] + "><any>(this.getChild(\"" + mInfo.name + "\"));");
										}
										else {
											printLogAndSave(classCodes, "\t\t\tthis." + _mNamePrefix + PinYinUtils.toPinyin(nameArr1[0]) + " = <" + nameArr1[1] + "><any>(this.getChildAt(" + childIndex + "));");
										}
									}else{
										if (_projectPublishSettings["getMemberByName"]) {
											printLogAndSave(classCodes, "\t\t\tthis." + _mNamePrefix + PinYinUtils.toPinyin(mInfo.name) + " = <fairygui." + PinYinUtils.toPinyin(mInfo.type) + "><any>(this.getChild(\"" + mInfo.name + "\"));");
										}
										else {
											printLogAndSave(classCodes, "\t\t\tthis." + _mNamePrefix + PinYinUtils.toPinyin(mInfo.name) + " = <fairygui." + PinYinUtils.toPinyin(mInfo.type) + "><any>(this.getChildAt(" + childIndex + "));");
										}
									}
								}
							}else if(_loadType == "2"){
								//方法二：通过成员的参数，直接加载类名
								if (mInfo.name){
									if(mInfo.src){
										if(mInfo.pkg){
											if (_projectPublishSettings["getMemberByName"]) {
												printLogAndSave(classCodes, "\t\t\tthis." + _mNamePrefix + PinYinUtils.toPinyin(mInfo.name) + " = <" + _importPackageName + mInfo.pkg + "." + mInfo.src + "><any>(this.getChild(\"" + mInfo.name + "\"));");
											}
											else {
												printLogAndSave(classCodes, "\t\t\tthis." + _mNamePrefix + PinYinUtils.toPinyin(mInfo.name) + " = <" + _importPackageName + mInfo.pkg + "." + mInfo.src + "><any>(this.getChildAt(" + childIndex + "));");
											}
										}else{
											if (_projectPublishSettings["getMemberByName"]) {
												printLogAndSave(classCodes, "\t\t\tthis." + _mNamePrefix + PinYinUtils.toPinyin(mInfo.name) + " = <" + _importPackageName + bindPackage + "." + mInfo.src + "><any>(this.getChild(\"" + mInfo.name + "\"));");
											}
											else {
												printLogAndSave(classCodes, "\t\t\tthis." + _mNamePrefix + PinYinUtils.toPinyin(mInfo.name) + " = <" + _importPackageName + bindPackage + "." + mInfo.src + "><any>(this.getChildAt(" + childIndex + "));");
											}
										}
									}else{
										if (_projectPublishSettings["getMemberByName"]) {
											printLogAndSave(classCodes, "\t\t\tthis." + _mNamePrefix + PinYinUtils.toPinyin(mInfo.name) + " = <fairygui." + PinYinUtils.toPinyin(mInfo.type) + "><any>(this.getChild(\"" + mInfo.name + "\"));");
										}
										else {
											printLogAndSave(classCodes, "\t\t\tthis." + _mNamePrefix + PinYinUtils.toPinyin(mInfo.name) + " = <fairygui." + PinYinUtils.toPinyin(mInfo.type) + "><any>(this.getChildAt(" + childIndex + "));");
										}
									}
								}
							}
						}
						childIndex++;
					}
				}				
				printLogAndSave(classCodes, "\t\t}");
				printLogAndSave(classCodes, "\t}");
				printLogAndSave(classCodes, "}");
				
				FileTool.writeFile(codeFolder.nativePath + File.separator + className + ".ts", classCodes.join("\r\n"));
			}
			
			callback.callOnSuccess();
			return true;
		}
		/**保存代码并打印日志*/
		private function printLogAndSave(arr:Array, str:String):Array{
			arr.push(str);
			printLog(str);
			return arr;
		}
		
		private function getFilePackage(packageStr:String):String{
			return packageStr.replace(new RegExp("\\.", "g"), File.separator);
		}
		
		/**
		 * 检测是否是
		 */
		private function checkIsUseDefaultName(name:String):Boolean{
			if (name.charAt(0) == "n" || name.charAt(0) == "c" || name.charAt(0) == "t"){
				return _isNaN(name.slice(1));
			}
			return false;
		}
		
		private function _isNaN(str:String):Boolean{
			if (isNaN(parseInt(str))){
				return false;
			}
			return true;
		}
		//-------------------------输出log到文件--------------------------
		
		/**将当前类打印成xml文件*/
		private function logXMLByObject(obj:Object, name:String):void{
			if(!_logPath || _logPath == ""){
				return;
			}
			var path:String = getLogXMLPath(name);
			try{
				var file:File = new File(path);
				var xml:XML = describeType(obj);
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.WRITE);
				fileStream.writeUTFBytes(xml.toXMLString());
				fileStream.close();
			} 
			catch(error:Error){
				_logPath = "";
				_callback.addMsg("打印XML文件出错，请检查配置的日志路径是否正确。检查文件写入权限。");
			}
		}
		
		private function printLog(log:String):void {
			if(!_logPath || _logPath == ""){
				return;
			}
			var path:String = getLogFilePath();
			try{
				var file:File = new File(path);
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.APPEND);
				fileStream.writeUTFBytes(log + "\n");
				fileStream.close();
			} 
			catch(error:Error){
				_logPath = "";
				_callback.addMsg("打印日志出错，请检查配置的日志路径是否正确。检查文件写入权限。");
			}
		}
		
		/**输出Object对象，为了防止递归太深，最高层级设置为4层*/
		private function printLogObject(name:String, obj:Object, level:int = 1):void{
			if(!_logPath || _logPath == ""){
				return;
			}
			if(level < 1){
				var level:int = 1;
			}else if(level > 4){
				return;
			}
			if(name){
				printLog(name);
			}
			for(var n:String in obj){
				var str:String = "";
				for(var i:int=0; i<level; i++){
					str += "\t";
				}
				printLog(str + n + ":" + obj[n]);
				if(obj[n] is String || obj[n] is int || obj[n] is Number){
					continue;
				}
				level++;
				printLogObject("", obj[n], level);
				level--;
			}
		}
		
		private function clearLogFile():void {
			if(!_logPath || _logPath == ""){
				return;
			}
			var path:String = getLogFilePath();
			var file:File = new File(path);
			if (file.exists) {
				file.deleteFile();
			}
		}
		
		private function getLogFilePath():String {
			return _logPath + File.separator +"log.txt";
		}
		private function getLogXMLPath(name:String):String{
			return _logPath + File.separator + name + ".xml";
		}
		private var first:Boolean = true;
	}
	
	
}