import QtQuick 2.7
import QtQuick.Controls 2.12
import QtQuick.Window 2.0
import QtMultimedia 5.12
import QtWebView 1.1
import Qt.labs.settings 1.1
ApplicationWindow{
    id: app
    visible: true
    visibility: "Maximized"
    color: 'transparent'
    title: 'YouTube Chat Speech'
    property int fs: width*0.02
    property bool editable: false
    property var aVoices: [
        'es-ES_EnriqueVoice',
        'es-ES_EnriqueV3Voice',
        'es-ES_LauraVoice',
        'es-ES_LauraV3Voice',
        'es-LA_SofiaVoice',
        'es-LA_SofiaV3Voice',
        'es-US_SofiaVoice',
        'es-US_SofiaV3Voice',
        'en-GB_CharlotteV3Voice',
        'en-GB_KateVoice',
        'en-GB_KateV3Voice',
        'en-GB_JamesV3Voice',
        'en-US_AllisonVoice',
        'en-US_AllisonV3Voice',
        'en-US_EmilyV3Voice',
        'en-US_OliviaV3Voice',
        'en-US_LisaVoice',
        'en-US_LisaV3Voice',
        'en-US_HenryV3Voice',
        'en-US_KevinV3Voice',
        'en-US_MichaelVoice',
        'en-US_MichaelV3Voice']


    onClosing: {
        close.accepted = true
        Qt.quit()
    }
    onVisibilityChanged: {
        if(app.visibility===ApplicationWindow.Maximized){
            app.editable=!app.editable
            showMode(app.editable)
        }
    }
    onActiveChanged: {
        //        if(active){
        //            app.editable=true
        //            showMode(app.editable)
        //        }
    }

    Audio {
        id: mp;
        onPlaybackStateChanged:{
            if(mp.playbackState===Audio.StoppedState){
                playlist.removeItem(0)
            }
        }
        playlist: Playlist {
            id: playlist
            onItemCountChanged:{
                xMsgList.actualizar(playlist)
            }
        }
    }
    //    Item{
    //        id: xMouseArea
    //        visible: false
    //        width: Screen.width
    //        height: Screen.desktopAvailableHeight
    //        MouseArea{
    //            anchors.fill: parent
    //            onClicked: app.flags=Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.WindowTransparentForInput
    //        }
    //    }
    Settings{
        id: apps
        property string uHtml: ''
        property string uUrl: ''
    }
    Item{
        id: xAppWV
        anchors.fill: parent
        //z:xApp.z+1
        //opacity: app.editable?1.0:0.65
        WebView{
            id: wv
            width: parent.width
            height: parent.height//*0.5
            //x:app.width+1280
            //            y: 100
            //url:"https://studio.youtube.com/live_chat?is_popout=1&v=V0nm81lBBUU"
            visible:false
            onLoadProgressChanged:{
                if(loadProgress===100){
                    tCheck.start()
                }
            }
        }
    }
    Item{
        id: xApp
        anchors.fill: parent
        //opacity: app.editable?1.0:0.65
        Rectangle{
            id: xLed
            width: 100
            height: width
            border.width: 4
            border.color: '#ff8833'
            radius: 10
            property bool toogle: false
            color: toogle?'red':'green'
            visible: false
            Text {
                id: info
                text: 'nada'
                font.pixelSize: 24
                width: xApp.width-20
                wrapMode: Text.WordWrap
                anchors.left: parent.left
                anchors.leftMargin: 20
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    Qt.quit()
                    app.editable=false
                    //console.log('Desactivando...')
                    showMode(app.editable)
                }
                Rectangle{
                    anchors.fill: parent
                    color: '#ff8833'
                }
            }
        }

        Row{
            id: mainRow
            width: parent.width
            height: parent.height
            XMsgList{
                id: xMsgList
                width: mainRow.width-xUserList.width
                border.width: app.editable?2:0
            }
            XUsersList{
                id: xUserList
                width: mainRow.width*0.25
                border.width: app.editable?2:0
            }
        }
    }
    Text{
        anchors.centerIn: parent
        font.pixelSize: 50
        text: wv.url
        color: 'red'
    }
    property string uMsg: 'null'
    Timer{
        id: tCheck
        running: false
        repeat: true
        interval: 100
        onTriggered: {
            running=false
            wv.runJavaScript('function doc(){var d=document.body.innerHTML; return d;};doc();', function(html){
                //console.log('Doc: '+html)
                if(html&&html!==apps.uHtml){
                    //unik.speak('yes')
                    //if(app.uMsg!==uMsgs[uMsgs.length-1]){
                    //mp.play()
                    //}
                    //yt-live-chat-text-message-renderer
                    wv.runJavaScript('function doc(){var d=document.body.innerText; return d;};doc();', function(html2){
                    //wv.runJavaScript('function doc(){var d=document.getElementsByTagName("div").innerText; return d;};doc();', function(html2){
                        //console.log('Html2: '+html2)
                        let mm0=html2.split('Di algo???\n')
                        let m0=mm0[0].split('\n')
                        //console.log('Html3: '+m0)
                        let uMsgs=[]
                        let uindex=0
                        if(m0.length>1){
                            for(var i=0;i<m0.length;i++){
                                if(m0[i]!==app.uMsg){
                                    if(m0[i].indexOf('M??S INFORMACI??N') < 0 && m0[i].indexOf('??Te damos la bienvenida al chat en vivo!') < 0 ){
                                        uMsgs.push(m0[i])
                                    }
                                }
                            }
                            /*for(i=uindex+1;i<m0.length;i++){
                                uMsgs.push(m0[i])
                            }*/
                        }
                        //console.log('Html4: '+uMsgs)
                        if(uMsgs.toString().indexOf('undefined dice')>=0)return
                        let nMsg=uMsgs[uMsgs.length-3]+' dice: '+uMsgs[uMsgs.length-2]
                        //console.log('Html5: '+nMsg)
                        if(isVM(nMsg)&&nMsg!==app.uMsg){
                            app.uMsg=nMsg//uMsgs[uMsgs.length-1]
                            xLed.toogle=!xLed.toogle
                            xLed.z=xLed.z+wv.z+1000
                            //mp.source='https://text-to-speech-demo.ng.bluemix.net/api/v3/synthesize?text=ricardo%20%20martin%20dice%20probando%20audio&voice=es-ES_EnriqueVoice&download=true&accept=audio%2Fmp3'
                            let mm0=app.uMsg.trim().split(' dice: ')
                            //console.log('mm0['+mm0[0]+']')
                            xUserList.addUser(mm0[0])
                            //console.log('User voice index: '+xUserList.getIndexVoice(mm0[0]))
                            if(!xUserList.userIsEnabled(mm0[0])){
                                //console.log('User disabled: '+mm0[0])

                                return
                            }
                            let msg=app.uMsg//.replace(mm0[0], mm0[0]+' dice ')
                            msg=msg.replace(/ /g, '%20').replace(/_/g, ' ')
                            //console.log('MSG: '+msg)
                            //playlist.addItem('https://text-to-speech-demo.ng.bluemix.net/api/v3/synthesize?text='+msg+'&voice=es-ES_EnriqueVoice&download=true&accept=audio%2Fmp3')
                            //playlist.addItem('https://text-to-speech-demo.ng.bluemix.net/api/v3/synthesize?text='+msg+'&voice='+app.aVoices[xUserList.getIndexVoice(mm0[0])]+'&download=true&accept=audio%2Fmp3')
                            let indexVoice=xUserList.getIndexVoice(mm0[0])
                            if(indexVoice<0)indexVoice=0
                            playlist.addItem('https://text-to-speech-demo.ng.bluemix.net/api/v3/synthesize?text='+msg+'&voice='+app.aVoices[indexVoice]+'&download=true&accept=audio%2Fmp3')
                            mp.play()
                            console.log('IV: '+indexVoice)
                            let mps=(''+mp.source).replace('file://', '')
                            info.text=mps+' '+unik.fileExist(mps)
                        }
                        //console.log('Html2: '+uMsgs.toString())
                        apps.uHtml=html
                        running=true
                        return
                    });
                }else{
                    //unik.speak('NO')
                    apps.uHtml=''
                    running=true
                    return
                }
                apps.uHtml=html
                running=true
            });
        }
    }
    Timer{
        id: tM
        running: false
        repeat: false
        interval: 3000
        onTriggered: {
            let code=''
            code+='import QtQuick 2.0\n'
            code+='Rectangle{\n'
            //code+=' z: xMsgList.z-1\n'
            code+=' color: "blue"\n'
            code+=' anchors.fill: parent\n'
            code+=' MouseArea{\n'
            code+='     anchors.fill: parent\n'
            code+='    onClicked: { \n'
            code+='         console.log("Ejecutando...")\n'
            code+='         parent.color="red"\n'
            code+='         app.showMode(false)\n'
            code+='     }\n'
            code+=' }\n'
            code+=' Component.onCompleted: {\n'
            //code+='     mainRow.z=z+1\n'
            code+=' }\n'
            code+='}\n'
            let comp=Qt.createQmlObject(code, xApp, 'code')
        }
    }
    Timer{
        id: tLink
        running: false
        repeat: true
        interval: 2000
        onTriggered: {
                let  cb = clipboard.getText()
                if(cb.indexOf('https://studio.youtube.com/live_chat?is_popout=1&v=')>=0){
                    //console.log('cb:' + cb)
                    wv.url=cb
                    clipboard.setText('Enlace de youtube chat capturado.')
                    let msg='Enlace de chat capturado.'
                    playlist.addItem('https://text-to-speech-demo.ng.bluemix.net/api/v3/synthesize?text='+msg+'&voice=es-ES_EnriqueVoice&download=true&accept=audio%2Fmp3')
                }

        }
    }
    Component.onCompleted: {
        let args=Qt.application.arguments
        if(args.length>2){
            if(args[1].indexOf('https://studio.youtube.com/live_chat')>=0){
                wv.url=args[1]
                return
            }
            if(args[2].indexOf('https://studio.youtube.com/live_chat')>=0){
                wv.url=args[2]
                return
            }
            if(args[3].indexOf('https://studio.youtube.com/live_chat')>=0){
                wv.url=args[3]
                return
            }
        }else{
            tLink.start()
        }

        //Ejemplo que funciona.
        //wv.url='https://studio.youtube.com/live_chat?is_popout=1&v=XE-2kN3Szqc'
    }
    function isVM(msg){
        if(msg.indexOf('http:/')>=0||msg.indexOf('https:/')>=0){
            return false
        }
        //Nightbot
        if(msg.indexOf('Nightbot')>=0){
            return false
        }
        return true
    }
    function showMode(b){
        if(b){
            app.flags=Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint// | Qt.WindowTransparentForInput
            //app.flags=Qt.Window | Qt.WindowStaysOnTopHint// | Qt.WindowTransparentForInput
            //app.flags=Qt.Window | Qt.WindowStaysOnTopHint
            //app.raise()
            //app.modality=Qt.ApplicationModal
            //app.active=true
        }else{
            app.flags=Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.WindowTransparentForInput
            //app.flags=Qt.Window | Qt.WindowStaysOnTopHint | Qt.WindowTransparentForInput
        }
    }
}
