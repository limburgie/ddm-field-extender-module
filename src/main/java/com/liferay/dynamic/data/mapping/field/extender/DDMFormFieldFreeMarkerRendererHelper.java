/**
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
 *
 * The contents of this file are subject to the terms of the Liferay Enterprise
 * Subscription License ("License"). You may not use this file except in
 * compliance with the License. You can obtain a copy of the License by
 * contacting Liferay, Inc. See the License for the specific language governing
 * permissions and limitations under the License, including but not limited to
 * distribution rights of the Software.
 *
 *
 *
 */

package com.liferay.dynamic.data.mapping.field.extender;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import javax.servlet.http.HttpServletRequest;

import org.osgi.service.component.annotations.*;

import com.liferay.portal.kernel.editor.Editor;
import com.liferay.portal.kernel.servlet.BrowserSnifferUtil;
import com.liferay.portal.kernel.util.PropsKeys;
import com.liferay.portal.kernel.util.PropsUtil;
import com.liferay.portal.kernel.util.Validator;

/**
 * @author Pedro Queiroz
 */
@Component(
	immediate = true, service = DDMFormFieldFreeMarkerRendererHelper.class
)
public class DDMFormFieldFreeMarkerRendererHelper {

	public static Editor getEditor(HttpServletRequest request) {
		if (!BrowserSnifferUtil.isRtf(request)) {
			return _editors.get("simple");
		}

		if (Validator.isNull(_TEXT_HTML_EDITOR_WYSIWYG_DEFAULT)) {
			return _editors.get(_EDITOR_WYSIWYG_DEFAULT);
		}

		if (!_editors.containsKey(_TEXT_HTML_EDITOR_WYSIWYG_DEFAULT)) {
			return _editors.get(_EDITOR_WYSIWYG_DEFAULT);
		}

		return _editors.get(_TEXT_HTML_EDITOR_WYSIWYG_DEFAULT);
	}

	@Reference(
		cardinality = ReferenceCardinality.MULTIPLE,
		policy = ReferencePolicy.DYNAMIC,
		policyOption = ReferencePolicyOption.GREEDY
	)
	protected void addEditor(Editor editor) {
		_editors.put(editor.getName(), editor);
	}

	protected void removeEditor(Editor editor) {
		_editors.remove(editor.getName());
	}

	private static final String _EDITOR_WYSIWYG_DEFAULT = PropsUtil.get(
		PropsKeys.EDITOR_WYSIWYG_DEFAULT);

	private static final String _TEXT_HTML_EDITOR_WYSIWYG_DEFAULT =
		PropsUtil.get("editor.wysiwyg.portal-impl.portlet.ddm.text_html.ftl");

	private static final Map<String, Editor> _editors =
		new ConcurrentHashMap<>();

}