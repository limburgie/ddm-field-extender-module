package com.liferay.dynamic.data.mapping.field.extender;

import java.util.Locale;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import com.liferay.dynamic.data.mapping.render.BaseDDMFormFieldValueRenderer;
import com.liferay.dynamic.data.mapping.render.DDMFormFieldValueRenderer;
import com.liferay.dynamic.data.mapping.render.ValueAccessor;
import com.liferay.dynamic.data.mapping.storage.DDMFormFieldValue;
import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.service.UserLocalService;
import com.liferay.portal.kernel.util.Portal;
import com.liferay.portal.kernel.util.StringPool;

/**
 * This class tells Liferay how to render the user inside the overview list.
 * In this case, the value (a screen name) is converted to the users's full name.
 * If that fails or if the screen name is null or empty,
 */
@Component(immediate = true, service = DDMFormFieldValueRenderer.class)
public class UserDDMFormFieldValueRenderer extends BaseDDMFormFieldValueRenderer {

	@Reference private UserLocalService userLocalService;
	@Reference private Portal portal;

	@Override
	protected ValueAccessor getValueAcessor(Locale locale) {
		return new ValueAccessor(locale) {
			@Override
			public String get(DDMFormFieldValue ddmFormFieldValue) {
				String screenName = ddmFormFieldValue.getValue().getString(locale);

				if (screenName != null) {
					try {
						return userLocalService.getUserByScreenName(portal.getDefaultCompanyId(), screenName).getFullName();

					} catch (PortalException e) {
						return screenName;
					}
				}

				return StringPool.BLANK;
			}
		};
	}

	@Override
	public String getSupportedDDMFormFieldType() {
		return "ddm-users";
	}
}
