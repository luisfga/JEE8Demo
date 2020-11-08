<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<s:set var="rootPath">${pageContext.request.contextPath}</s:set>
<html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0" charset="UTF-8">
        <title><s:text name="main.title"/></title>
        <link rel="stylesheet" href="${rootPath}/css/main.css"/>
        <link rel="stylesheet" href="${rootPath}/css/dashboard.css"/>
        <script>
            function toggleMenu() {
                console.log("Display = " + document.getElementById("menu-bar").style.display);
                if (document.getElementById("menu-bar").style.display === ""){
                    console.log("Agora -> none");
                    document.getElementById("menu-bar").style.display = "none";
                } else {
                    console.log("Agora -> mostrar");
                    document.getElementById("menu-bar").style.display = "";
                }
            }

            function closeNav() {
              document.getElementById("menu-bar").style.display = "none";
            }
        </script>
    </head>

    <body>
        <div class="top-row">
            <span class="menu-toggle" onclick="toggleMenu()">&#9776;</span>
        </div>

        <table class="content-table">
            <tr>
                <td class="side-menu-td" id="menu-bar">
                    <div class="side-menu">
                        <br>
                        <!-- Opções apenas para a role ADMIN -->
                        <shiro:hasRole name="Admin">
                            <div class="menu-title">${pageContext.request.userPrincipal.name}</div>
                            <br><br>
                            <s:url action="admin" var="adminUrl" />
                            <s:a href="%{adminUrl}" class="menu-item">Administer the system</s:a><br>
                            
                            <s:url action="logout" var="logoutUrl"/>
                            <s:a href="%{logoutUrl}" class="menu-item">Logout</s:a>
                        </shiro:hasRole>     
                    </div>
                </td>
                <td class="content-td">
                    <div class="content">
                        
                        <!-- ROLES -->
                        <div class="tb">
                            <div class="tb-caption">
                                <div class="cap-title"><s:text name="roles"/></div>
                            </div>
                            <div id="rolesContainer" class="tag-container">
                                <s:iterator value="roles">
                                <span id="role-<s:property value="roleName"/>" 
                                      class="item-tag" 
                                      draggable="true" 
                                      ondragstart="onDragStart(event);"><s:property value="roleName"/></span>
                                </s:iterator>
                            </div>
                            <div class="tb-last-line">
                                <div class="input-group">
                                    <s:textfield id="role" name="role" theme="simple"/>
                                    <a onclick="addRole()" class="action-button">+</a>
                                    <div id="roleMessage" class="info-msg"></div>
                                </div>
                                <img 
                                    ondragover="onDragOver(event);" 
                                    ondrop="onRoleDrop(event);" 
                                    src="${rootPath}/images/trash-can.png" 
                                    class="trash-can-icon" title="Drop here to remove"/>
                            </div>
                        </div>

                        <!-- PERMISSÕES -->
                        <div class="tb">
                            <div class="tb-caption">
                                <div class="cap-title"><s:text name="permissions"/></div>
                            </div>
                            <div id="permissionsContainer" class="tag-container">
                                <s:iterator value="permissions">
                                <span id="perm-<s:property value="permissionName"/>" 
                                      class="item-tag" 
                                      draggable="true" 
                                      ondragstart="onDragStart(event);"><s:property value="permissionName"/></span>
                                </s:iterator>
                            </div>
                            <div class="tb-last-line">
                                <div class="input-group">
                                    <s:textfield id="permission" name="permission" theme="simple"/>
                                    <a onclick="addPermission()" class="action-button">+</a>
                                    <div id="permissionMessage" class="info-msg"></div>
                                </div>
                                <img 
                                    class="trash-can-icon" 
                                    ondragover="onDragOver(event);" 
                                    ondrop="onPermissionDrop(event);" 
                                    src="${rootPath}/images/trash-can.png" 
                                    title="Drop here to remove"/>
                            </div>
                        </div>

                        <!-- ROLES & PERMISSÕES -->
                        <div class="tb">
                            <div class="tb-caption">
                                <div class="cap-title"><s:text name="roles"/> & <s:text name="permissions"/></div>
                            </div>
                            <div id="rolePermissionsContainer" class="tag-container" ondragover="onDragOver(event)" ondrop="onRolePermissionDrop(event)">
                                <s:iterator value="selectedRolePermissions">
                                <span id="role-perm-<s:property value="permissionName"/>" 
                                      class="item-tag" 
                                      draggable="true" 
                                      ondragstart="onDragStart(event);"><s:property value="permissionName"/></span>
                                </s:iterator>
                                <span id="role-perm-placeholder" class="placeholder-msg"><s:text name="info.drop.permission.here"/></span>
                            </div>
                            <div class="tb-last-line">
                                <div class="input-group">
                                    <s:select headerKey="-1" headerValue="Select a role" 
                                              key="roles" 
                                              list="roles" 
                                              listKey="roleName" 
                                              listValue="roleName" 
                                              multiple="false" 
                                              size="1" 
                                              listTitle="Select"
                                              onchange="roleSelected()"
                                              value="selectedRole" theme="simple"/>
                                    <div id="rolePermissionMessage" class="info-msg"></div>
                                </div>
                            </div>
                        </div>     

                        <!--TABELA USUÁRIOS-->
                        <div class="tb">
                            <div class="tb-caption">
                                <div class="cap-title"><s:text name="users"/></div>
                            </div>
                            <div id="users-search">
                                <s:textfield id="user" name="user" theme="simple"/>
                                <s:url var="urlSearch" action="searchUser"/>
                                <s:a href="%{urlSearch}" class="action-button">Buscar</s:a>                                 
                            </div>
                        </div>

                    </div>
                </td>
            </tr>
        </table>

    </body>
    
    <script>
    /*XXXXXXXXXXXXXXXXXXX
      Grupos & Permissões
    XXXXXXXXXXXXXXXXXXXXX*/        
    function onRolePermissionDrop(event) {
        event.preventDefault();//cancel forward trickery

        //get tagElementId from drag event
        let tagElementId = event.dataTransfer.getData('text');
        
        var roles = document.getElementById('roles');
        
        //check if its a 'role-' tag
        if (tagElementId.startsWith("role-") === true){
            var roleName = tagElementId.replace("role-","");
            //set selected role
            for (var i = 0; i < roles.options.length; i++) {
                if (roles.options[i].text === roleName) {
                    roles.selectedIndex = i;
                    var message = '<s:text name="info.role.selected"/>';
                    showMessage('rolePermissionMessage', message.replace("{0}",roleName), "success-msg", false);
                    roleSelected();
                    return;
                }
            }
        }

        //if the droped tag is not a 'role-', check if a 'perm-'
        if (tagElementId.startsWith("perm-") === false){
            return;
        }
        
        //so its a 'perm-'. Check for selectedRole
        if (roles.selectedIndex === 0) {
            showMessage('rolePermissionMessage','<s:text name="info.first.select.role"/>', "fail-msg", true);
            return;
        }
        
        let permissionTagElem = document.getElementById(tagElementId);

        console.log("Permissão sendo associada: " + permissionTagElem.innerHTML);

        var rolePermissionsContainer = document.getElementById('rolePermissionsContainer');
        var childNodes = rolePermissionsContainer.childNodes;
        //checar se já não existe essa div no target
        var alreadyContains = false;
        for (var i = 0; i < childNodes.length; i++) {
            //pegar apenas os nodes que são 'tags' html
             if (childNodes[i].nodeType === Node.ELEMENT_NODE) {
                //se o id da permissão for igual ao id de qualquer permissão já na lista
                //precisa retirar o prefixo 'role-'
                var childNodeOriginalId = childNodes[i].id;
                childNodeOriginalId = childNodeOriginalId.replace("role-","");
                if (childNodeOriginalId === permissionTagElem.id){
                    alreadyContains = true;
                    break;
                }
             }
        }
        console.log("Já tem? " + alreadyContains);
        if(!alreadyContains) {
            removeRolePermissionsPlaceHolder();
            var clonedChild = permissionTagElem.cloneNode(true);
            clonedChild.id = "role-"+permissionTagElem.id;
            rolePermissionsContainer.appendChild(clonedChild);
            rolePermissionsContainer.appendChild(document.createTextNode(" "));//<- whitespace
            console.log("Adicionou!");
            
            //ordenar tags alfabeticamente
            var orderingChildNodes = rolePermissionsContainer.childNodes;
            var nodesArray = [];
            for (var i in orderingChildNodes) {
                if (orderingChildNodes[i].nodeType === Node.ELEMENT_NODE) { // get rid of the whitespace text nodes
                    nodesArray.push(orderingChildNodes[i]);
                }
            }
            nodesArray.sort(function(a, b) {
                return a.innerHTML === b.innerHTML? 0 : (a.innerHTML > b.innerHTML ? 1 : -1);
            });
            for (i = 0; i < nodesArray.length; ++i) {
                rolePermissionsContainer.appendChild(nodesArray[i]);
                rolePermissionsContainer.appendChild(document.createTextNode(" "));//<- whitespace
            }
        }

        event.preventDefault();
    }
    
    function roleSelected(){
        
        //check if the selected one was the 'empty' option
        let roles = document.getElementById('roles');
        if (roles.selectedIndex === 0) {
            resetMessageContainer('rolePermissionMessage');
            let rolePermissionsContainer = document.getElementById("rolePermissionsContainer");
            rolePermissionsContainer.innerHTML='<span id="role-perm-placeholder" class="placeholder-msg"><s:text name="info.drop.permission.here"/></span>';
            return;
        }
        let selectedRole = roles.options[roles.selectedIndex].text;
        
        //load permissions of the selectedRole
        let xhttp = new XMLHttpRequest();
        xhttp.onreadystatechange = function(){
            if (this.readyState === 4 && this.status === 200) {
                let jsonResponse = JSON.parse(this.responseText);
                console.log(jsonResponse);
                let selectedRolePermissions = jsonResponse.selectedRolePermissions;
                let rolePermissionsContainer = document.getElementById('rolePermissionsContainer');
                rolePermissionsContainer.innerHTML = '';
                for(let i=0; i < selectedRolePermissions.length; i++){
                    let permissionName = selectedRolePermissions[i].permissionName;
                    rolePermissionsContainer.innerHTML += '<span class="item-tag" id="role-perm-'+permissionName+'" draggable="true" ondragstart="onDragStart(event);">'+permissionName+'</span> ';
                }
                if (selectedRolePermissions.length === 0){
                    rolePermissionsContainer.innerHTML='<span id="role-perm-placeholder" class="placeholder-msg"><s:text name="info.role.without.permissions"/></span>';
                }
            }
        };
        let json = {"selectedRole": selectedRole};
        xhttp.open('POST', '<s:url action="adminGetRolePermissions"/>', true);
        xhttp.setRequestHeader('Content-Type', 'application/json');
        xhttp.send(JSON.stringify(json));
        
        //set message
        let message = '<s:text name="info.role.selected"/>';
        showMessage('rolePermissionMessage', message.replace("{0}", selectedRole), "success-msg", false);
        console.log("roleSelected()");
    }
    
    function resetMessageContainer(targetId){
        var messageContainer = document.getElementById(targetId);
        messageContainer.innerHTML = '';
        messageContainer.className = 'info-msg';
    }

    function showMessage(targetId, message, styleClassName, withTimeOut){
        var messageContainer = document.getElementById(targetId);
        messageContainer.innerHTML = message;
        messageContainer.className = styleClassName;
        if (withTimeOut) {
            setTimeout(function(){
                messageContainer.innerHTML = '';
                messageContainer.className = 'info-msg';
            },5000);
        }
    }
    
    function removeRolePermissionsPlaceHolder(){
        var placeholder = document.getElementById('role-perm-placeholder');
        var container = document.getElementById('rolePermissionsContainer');
        if (placeholder){
            container.removeChild(placeholder);
        }
    }

    /*XXXXXXXXXXXXXXXXXXXXXXXX
    Generic Drag&Drop Handlers
    XXXXXXXXXXXXXXXXXXXXXXXXXX*/
    function onDragStart(event) {
        event.dataTransfer.setData('text/plain', event.target.id);
    }
    function onDragOver(event) {
        event.preventDefault();
    }
    function onDragEnd(event) {
        event.preventDefault();
    }

    /*XXXXXXXXXXXXXXXXXXXXXXX
    ROLES especific functions
    XXXXXXXXXXXXXXXXXXXXXXXXX*/
    function onRoleDrop(event) {
        event.preventDefault();//cancel forward trickery
        let roleTagId = event.dataTransfer.getData('text');

        //only let roles be handled
        console.log("roleTagId = " + roleTagId);
        console.log("roleTagId.startsWith(role-) = " + roleTagId.startsWith("role-"));
        console.log("roleTagId.startsWith(role-) !== true = " + roleTagId.startsWith("role-") !== true);
        if (roleTagId.startsWith("role-") === false){
            return;
        }

        let roleTagElem = document.getElementById(roleTagId);

        console.log("Role sendo deletada: " + roleTagElem.innerHTML);
        let r = confirm("Delete '"+roleTagElem.innerHTML+"'");
        if(r === true){
            console.log("delete");
            deleteRole(roleTagElem);
        } else {
            console.log("cancel");
        }

    }

    function addRole(){
        let role = document.getElementById('role').value;
        if (role === '') return;
        let xhttp = new XMLHttpRequest();

        //callback
        xhttp.onreadystatechange = function() {
            if (this.readyState === 4 && this.status === 200) {
                let roleMessage = document.getElementById("roleMessage");
                let jsonResponse = JSON.parse(this.responseText);
                console.log(jsonResponse);
                let rolesContainer = document.getElementById("rolesContainer");
                roleMessage.innerHTML = jsonResponse.message;
                if(jsonResponse.success === true){
                    roleMessage.className = "success-msg";
                    rolesContainer.innerHTML += '<span class="item-tag" id="role-'+role+'" draggable="true" ondragstart="onDragStart(event);">'+role+'</span> ';
                    //add to roles dropdown
                    var roles = document.getElementById('roles');
                    roles.options[roles.options.length] = new Option(role, role);
                } else {
                    roleMessage.className = "fail-msg";
                }
                setTimeout(function(){
                    roleMessage.innerHTML = '';
                    roleMessage.className = "info-msg"; //style normal
                },10000);
            }
        };

        // create a JSON object
        let json = {"role": role};
        xhttp.open('POST', '<s:url action="adminAddRole"/>', true);
        xhttp.setRequestHeader('Content-Type', 'application/json');
        xhttp.send(JSON.stringify(json));
    }
    function deleteRole(roleTagElem){
        let role = roleTagElem.innerHTML;
        let xhttp = new XMLHttpRequest();
        //callback
        xhttp.onreadystatechange = function() {
            if (this.readyState === 4 && this.status === 200) {
                let messageContainer = document.getElementById("roleMessage");
                let jsonResponse = JSON.parse(this.responseText);
                console.log(jsonResponse);
                messageContainer.innerHTML = jsonResponse.message;
                if(jsonResponse.success === true){
                    messageContainer.className = "success-msg";
                    roleTagElem.parentNode.removeChild(roleTagElem);
                    var roles = document.getElementById("roles");
                    roles.selectedIndex = 0;
                    for (var i=0; i < roles.length; i++){
                        if(roles.options[i].text === role){
                            roles.options[i] = null;
                            break;
                        }
                    }
                    roleSelected();
                } else {
                    messageContainer.className = "fail-msg";
                }
                setTimeout(function(){
                    messageContainer.innerHTML = '';
                    messageContainer.className = "info-msg"; //style normal
                },5000);
            }
        };

        // create a JSON object
        let json = {"role": role};
        xhttp.open('POST', '<s:url action="adminDeleteRole"/>', true);
        xhttp.setRequestHeader('Content-Type', 'application/json');
        xhttp.send(JSON.stringify(json));
    }
    
    /*XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    PERMISSIONS especific functions
    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX*/
    function onPermissionDrop(event) {
        event.preventDefault();
        let permissionTagId = event.dataTransfer.getData('text');

        //only let permissions be handled
        console.log("permissionTagId = " + permissionTagId);
        console.log("permissionTagId.startsWith(perm-) = " + permissionTagId.startsWith("perm-"));
        console.log("permissionTagId.startsWith(perm-) !== true = " + permissionTagId.startsWith("perm-") !== true);
        if (permissionTagId.startsWith("perm-") === false){
            return;
        }

        let permissionTagElem = document.getElementById(permissionTagId);

        console.log("Permissão sendo deletada: " + permissionTagElem.innerHTML);
        let r = confirm("Delete '"+permissionTagElem.innerHTML+"'");
        if(r === true){
            console.log("delete");
            deletePermission(permissionTagElem);
        } else {
            console.log("cancel");
        }

    }

    function addPermission(){
        let permission = document.getElementById('permission').value;
        if (permission === '') return;
        let xhttp = new XMLHttpRequest();

        //callback
        xhttp.onreadystatechange = function() {
            if (this.readyState === 4 && this.status === 200) {
                let permissionMessage = document.getElementById("permissionMessage");
                let jsonResponse = JSON.parse(this.responseText);
                console.log(jsonResponse);
                let permissionsContainer = document.getElementById("permissionsContainer");
                permissionMessage.innerHTML = jsonResponse.message;
                if(jsonResponse.success === true){
                    permissionMessage.className = "success-msg";
                    permissionsContainer.innerHTML += '<span class="item-tag" id="perm-'+permission+'" draggable="true" ondragstart="onDragStart(event);">'+permission+'</span> ';

                } else {
                    permissionMessage.className = "fail-msg";
                }
                setTimeout(function(){
                    permissionMessage.innerHTML = '';
                    permissionMessage.className = "info-msg"; //style normal
                },10000);
            }
        };

        // create a JSON object
        let json = {"permission": permission};
        xhttp.open('POST', '<s:url action="adminAddPermission"/>', true);
        xhttp.setRequestHeader('Content-Type', 'application/json');
        xhttp.send(JSON.stringify(json));
    }

    function deletePermission(permissionTagElem){
        let permission = permissionTagElem.innerHTML;
        let xhttp = new XMLHttpRequest();
        //callback
        xhttp.onreadystatechange = function() {
            if (this.readyState === 4 && this.status === 200) {
                let messageContainer = document.getElementById("permissionMessage");
                let jsonResponse = JSON.parse(this.responseText);
                console.log(jsonResponse);
                messageContainer.innerHTML = jsonResponse.message;
                if(jsonResponse.success === true){
                    messageContainer.className = "success-msg";
                    permissionTagElem.parentNode.removeChild(permissionTagElem);
                } else {
                    messageContainer.className = "fail-msg";
                }
                setTimeout(function(){
                    messageContainer.innerHTML = '';
                    messageContainer.className = "info-msg"; //style normal
                },5000);
            }
        };

        // create a JSON object
        let json = {"permission": permission};
        xhttp.open('POST', '<s:url action="adminDeletePermission"/>', true);
        xhttp.setRequestHeader('Content-Type', 'application/json');
        xhttp.send(JSON.stringify(json));
    }

    </script>
</html>