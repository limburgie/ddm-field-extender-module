
<#--START INIT-->

<#-- Tag libraries -->

<#assign fmt = PortalJspTagLibs["/WEB-INF/tld/fmt.tld"] />

<#-- CSS class -->

<#assign cssClass = "" />

<#if fieldStructure.width??>
	<#if stringUtil.equals(fieldStructure.width, "large")>
		<#assign cssClass = "input-large" />
	<#elseif stringUtil.equals(fieldStructure.width, "medium")>
		<#assign cssClass = "input-medium" />
	<#elseif stringUtil.equals(fieldStructure.width, "small")>
		<#assign cssClass = "input-small" />
	</#if>
</#if>


<#-- Repeatable -->

<#assign repeatable = false />

<#if stringUtil.equals(fieldStructure.repeatable, "true") && (!ignoreRepeatable?? || !ignoreRepeatable)>
	<#assign repeatable = true />
</#if>

<#-- Field name -->

<#assign
fieldNamespace = "_INSTANCE_" + fieldStructure.fieldNamespace

fieldName = fieldStructure.name

parentName = parentFieldStructure.name!""
parentType = parentFieldStructure.type!""

isChildField = validator.isNotNull(parentName) && (stringUtil.equals(parentType, "radio") || stringUtil.equals(parentType, "select"))
/>

<#if isChildField>
	<#assign fieldName = parentName />
</#if>

<#assign
namespace = namespace!""

namespacedFieldName = "${namespace}${fieldName}${fieldNamespace}"

namespacedParentName = "${namespace}${parentName}"
/>

<#-- Data -->

<#assign data = {
"fieldName": fieldStructure.name,
"fieldNamespace": fieldNamespace,
"repeatable": repeatable?string
}>

<#-- Predefined value -->

<#assign predefinedValue = fieldStructure.predefinedValue!"" />

<#if isChildField>
	<#assign predefinedValue = parentFieldStructure.predefinedValue!"" />
</#if>

<#-- Field value -->

<#assign
fieldValue = predefinedValue
fieldRawValue = ""
hasFieldValue = false
/>

<#if fields?? && fields.get(fieldName)??>
	<#assign
	field = fields.get(fieldName)

	valueIndex = getterUtil.getInteger(fieldStructure.valueIndex)

	fieldValue = field.getRenderedValue(requestedLocale, valueIndex)
	fieldRawValue = field.getValue(requestedLocale, valueIndex)!
	/>

	<#if validator.isNotNull(fieldValue)>
		<#assign hasFieldValue = true />
	</#if>
</#if>

<#-- Disabled -->

<#assign disabled = false />

<#if stringUtil.equals(fieldStructure.disabled, "true")>
	<#assign disabled = true />
</#if>

<#-- Label -->

<#assign label = fieldStructure.label!"" />

<#if stringUtil.equals(fieldStructure.showLabel, "false")>
	<#assign label = "" />
</#if>

<#-- Required -->

<#assign required = false />

<#if stringUtil.equals(fieldStructure.required, "true")>
	<#assign required = true />
</#if>

<#-- Util -->

<#function escape value="">
	<#if value?is_string>
		<#return htmlUtil.escape(value)>
	<#else>
		<#return value>
	</#if>
</#function>

<#function escapeAttribute value="">
	<#if value?is_string>
		<#return htmlUtil.escapeAttribute(value)>
	<#else>
		<#return value>
	</#if>
</#function>

<#function escapeCSS value="">
	<#if value?is_string>
		<#return htmlUtil.escapeCSS(value)>
	<#else>
		<#return value>
	</#if>
</#function>

<#function escapeJS value="">
	<#if value?is_string>
		<#return htmlUtil.escapeJS(value)>
	<#else>
		<#return value>
	</#if>
</#function>

<#assign dlAppServiceUtil = serviceLocator.findService("com.liferay.document.library.kernel.service.DLAppService") />

<#function getFileEntry fileJSONObject>
	<#assign fileEntryUUID = fileJSONObject.getString("uuid") />

	<#if fileJSONObject.getLong("groupId") gt 0>
		<#assign fileEntryGroupId = fileJSONObject.getLong("groupId") />
	<#else>
		<#assign fileEntryGroupId = scopeGroupId />
	</#if>

	<#return dlAppServiceUtil.getFileEntryByUuidAndGroupId(fileEntryUUID, fileEntryGroupId)!"">
</#function>

<#function getFileEntryURL fileEntry>
	<#return themeDisplay.getPathContext() + "/documents/" + fileEntry.getRepositoryId()?c + "/" + fileEntry.getFolderId()?c + "/" +  httpUtil.encodeURL(htmlUtil.unescape(fileEntry.getTitle()), true) + "/" + fileEntry.getUuid()>
</#function>

<#function getFileJSONObject fieldValue>
	<#return jsonFactoryUtil.createJSONObject(fieldValue)>
</#function>

<#assign journalArticleLocalService = serviceLocator.findService("com.liferay.journal.service.JournalArticleLocalService") />

<#function fetchLatestArticle journalArticleJSONObject>
	<#assign resourcePrimKey = journalArticleJSONObject.getLong("classPK") />

	<#return journalArticleLocalService.fetchLatestArticle(resourcePrimKey)!"">
</#function>

<#-- Token -->

<#assign
authTokenUtil = serviceLocator.findService("com.liferay.portal.kernel.security.auth.AuthTokenUtil")

ddmAuthToken = authTokenUtil.getToken(request, themeDisplay.getPlid(), "com_liferay_dynamic_data_mapping_web_portlet_DDMPortlet")
/>

<#assign data = data + {
"ddmAuthToken": ddmAuthToken
}>

<#--END INIT-->


<#assign userLocalService = serviceLocator.findService("com.liferay.portal.kernel.service.UserLocalService")>
<#assign multiple = false>
<#if fieldStructure.multiItem?? && (escape(fieldStructure.multiItem) == "true")>
	<#assign multiple = true>
</#if>

<@liferay_aui["field-wrapper"] data=data helpMessage=escape(fieldStructure.tip)>
	<#if fieldValue = "">
		<#assign values = []>
	<#else>
		<#assign values = fieldValue?split(",", "r")>
	</#if>
	<#assign users = userLocalService.getUsers(-1, -1)>

	<@liferay_aui.input cssClass=cssClass label=escape(label) name=namespacedFieldName type="text" value=fieldValue id="${namespacedFieldName}_hiddenUserList" style="display:none;">
		<#if required>
			<@liferay_aui.validator name="required" />
		</#if>
	</@liferay_aui.input>
<style>
	b {
		font-weight: bold;
	}
</style>
<div id="userContainer">
	<input type="text" id="${namespacedFieldName}_userInput" name="user_input" value="" title="Users" />
	<ul id="${namespacedFieldName}_userList" class="helper-clearfix textboxlistentry-holder unstyled"></ul>
</div>
<script type="text/javascript">
	YUI().use('autocomplete', 'autocomplete-highlighters', function(Y) {
				var users = [
                <#list users as user>
				
					<#--  <#assign value = user>  -->
					<#assign value = user.screenName>
					<#assign label = user.fullName>
                    {displayname:"${value}",fullname:"${label} - ${value}"}<#if user_has_next>,</#if>
				</#list>
				];

				var defaultUsers =  [
                <#list values as user>
                    "${user}"<#if user_has_next>,</#if>
				</#list>
				];

				var selected = [];
				var clear = false;

				init();

				Y.one('#${namespacedFieldName}_userInput').plug(Y.Plugin.AutoComplete, {
					resultFilters: customFilter,
					resultHighlighter: 'phraseMatch',
					source: users,
					resultTextLocator: 'fullname',
					on: {
						select: function(event) {
							var item = event.result.raw;
							if (isUniqueInList(item.displayname)) {
                            <#if !multiple>
                                selected = [];
                                Y.one('[id="${namespacedFieldName}_userList"]').get('childNodes').remove();
							</#if>
								debugger;
								selected.push(item);

								updateHiddenUserList();

								addUserItem(item);

								addRemoveUserItemEvent(item);
							}
							clear = true;
						},
						activeItemChange: function(e) {
							if (clear) {
								clear = false;
								Y.one('#${namespacedFieldName}_userInput').set("value","");
							}

						}
					}
				});

				function init() {
					for(var i = 0; i < defaultUsers.length; i++) {
						var item = defaultUsers[i];
						var user = {displayname:item,fullname:item};

						for(var j = 0; j < users.length; j++) {
							if (users[j].displayname == item) {
								user = users[j];
								break;
							}
						}
						selected.push(user);

						addUserItem(user);

						addRemoveUserItemEvent(user);
					}
					updateHiddenUserList();
				}

				function customFilter(query, results) {
					query = query.toLowerCase();

					return Y.Array.filter(results, function (result) {
						return result.text.toLowerCase().indexOf(query) !== -1;
					});
				}

				function isUniqueInList(name) {
					var names = [];
					for(var i = 0; i < selected.length; i++) {
						names.push(selected[i].displayname);
					}
					return (names.indexOf(name) == -1);
				}

				function updateHiddenUserList() {
					var values = [];
					for(var i = 0; i < selected.length; i++) {
						values.push(selected[i].displayname);
					}
					console.log(values);
					Y.one('[id$="${namespacedFieldName}_hiddenUserList"]').set("value", values);
				}

				function addUserItem(item) {
					Y.one('[id="${namespacedFieldName}_userList"]').append('<li class="yui3-widget component textboxlistentry" id="${namespacedFieldName}_userItem_'+item.displayname+'"><span class="textboxlistentry-text">' + item.fullname + '</span><span class="textboxlistentry-remove"><i class="icon icon-remove"></i></span></li>');
				}

				function addRemoveUserItemEvent(item) {
					Y.one('[id="${namespacedFieldName}_userItem_'+item.displayname+'"] .textboxlistentry-remove').on("click", function (e) {
						Y.one('[id="${namespacedFieldName}_userItem_'+item.displayname+'"]').remove();
						var index = selected.indexOf(item);
						if (index > -1) {
							selected.splice(index, 1);
						}
						updateHiddenUserList();
					});
				}
			}
	);
</script>
</@>