<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/views/include/taglib.jsp" %>

<!DOCTYPE html>
<!--[if IE 8]> <html lang="zh" class="ie8 no-js"> <![endif]-->
<!--[if IE 9]> <html lang="zh" class="ie9 no-js"> <![endif]-->
<!--[if !IE]><!-->
<html>
<!--<![endif]-->
<!-- BEGIN HEAD -->
<head>
    <title>${fns:getConfig('productName')} | 分配角色</title>
    <meta name="decorator" content="form"/>
    <%@include file="/views/include/treeview.jsp" %>
</head>

<body style="background: white;">
<div class="form-body" style="padding: 5px;">
    <div id="assignRole">
        <div style="float: left; width: 33%; border-right: 1px solid #A8A8A8;">
            <label>所在部门：</label>
            <div id="officeTree" class="ztree"></div>
        </div>
        <div style="float: left; width: 33%; padding-left: 20px;">
            <label>待选人员：</label>
            <div id="userTree" class="ztree"></div>
        </div>
        <div style="float: left; width: 33%; border-left: 1px solid #A8A8A8; padding-left: 20px;">
            <label>已选人员：</label>
            <div id="selectedTree" class="ztree"></div>
        </div>
        <div class="clearfix"></div>
    </div>
</div>

<%@include file="/views/include/foot.jsp" %>
<script type="text/javascript">
    var officeTree;
    var selectedTree;//zTree已选择对象

    // 初始化
    $(document).ready(function () {
        officeTree = $.fn.zTree.init($("#officeTree"), setting, officeNodes);
        selectedTree = $.fn.zTree.init($("#selectedTree"), setting, selectedNodes);
    });

    var setting = {
        view: {selectedMulti: false, nameIsHTML: true, showTitle: false, dblClickExpand: false},
        data: {simpleData: {enable: true}},
        callback: {onClick: treeOnClick}
    };

    var officeNodes = [
        <c:forEach items="${officeList}" var="office">
        {
            id: "${office.id}",
            pId: "${not empty office.parent?office.parent.id:0}",
            name: "${office.name}"
        },
        </c:forEach>];

    var pre_selectedNodes = [
        <c:forEach items="${userList}" var="user">
        {
            id: "${user.id}",
            pId: "0",
            name: "<font color='red' style='font-weight:bold;'>${user.name}</font>"
        },
        </c:forEach>];

    var selectedNodes = [
        <c:forEach items="${userList}" var="user">
        {
            id: "${user.id}",
            pId: "0",
            name: "<font color='red' style='font-weight:bold;'>${user.name}</font>"
        },
        </c:forEach>];

    var pre_ids = "${selectIds}".split(",");
    var ids = "${selectIds}".split(",");

    //点击选择项回调
    function treeOnClick(event, treeId, treeNode, clickFlag) {
        $.fn.zTree.getZTreeObj(treeId).expandNode(treeNode);
        if ("officeTree" == treeId) {
            $.get("${ctx}/sys/role/users?officeId=" + treeNode.id, function (userNodes) {
                $.fn.zTree.init($("#userTree"), setting, userNodes);
            });
        }

        if ("userTree" == treeId) {
            //alert(treeNode.id + " | " + ids);
            //alert(typeof ids[0] + " | " +  typeof treeNode.id);
            if ($.inArray(String(treeNode.id), ids) < 0) {
                selectedTree.addNodes(null, treeNode);
                ids.push(String(treeNode.id));
            }
        }

        if ("selectedTree" == treeId) {
            if ($.inArray(String(treeNode.id), pre_ids) < 0) {
                selectedTree.removeNode(treeNode);
                ids.splice($.inArray(String(treeNode.id), ids), 1);
            } else {
                top.$.jBox.tip("角色原有成员不能清除！", 'info');
            }
        }
    }

    function clearAssign() {
        var submit = function (v, h, f) {
            if (v == 'ok') {
                var tips = "";
                if (pre_ids.sort().toString() == ids.sort().toString()) {
                    tips = "未给角色【${role.name}】分配新成员！";
                } else {
                    tips = "已选人员清除成功！";
                }
                ids = pre_ids.slice(0);
                selectedNodes = pre_selectedNodes;
                $.fn.zTree.init($("#selectedTree"), setting, selectedNodes);
                top.$.jBox.tip(tips, 'info');
            } else if (v == 'cancel') {
                // 取消
                top.$.jBox.tip("取消清除操作！", 'info');
            }
            return true;
        };
        tips = "确定清除角色【${role.name}】下的已选人员？";
        top.$.jBox.confirm(tips, "清除确认", submit);
    }
</script>
</body>
</html>