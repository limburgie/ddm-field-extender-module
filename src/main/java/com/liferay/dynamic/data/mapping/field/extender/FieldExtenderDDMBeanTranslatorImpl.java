package com.liferay.dynamic.data.mapping.field.extender;

import com.liferay.dynamic.data.mapping.model.DDMFormField;
import com.liferay.dynamic.data.mapping.util.DDMBeanTranslator;
import com.liferay.dynamic.data.mapping.util.impl.DDMBeanTranslatorImpl;
import org.osgi.service.component.annotations.Component;

@Component(
        immediate = true,
        property = {
                // Take precendence over the default DDMBeanTranslatorImpl implementation
                "service.ranking:Integer=110"
        },
        service = DDMBeanTranslator.class
)
public class FieldExtenderDDMBeanTranslatorImpl extends DDMBeanTranslatorImpl {

    @Override
    public com.liferay.dynamic.data.mapping.kernel.DDMFormField translate(
            DDMFormField ddmFormField) {
        if (ddmFormField == null) {
            return null;
        }

        com.liferay.dynamic.data.mapping.kernel.DDMFormField
                translatedDDMFormField = super.translate(ddmFormField);

        if (ddmFormField.getType().equals("ddm-rest-select")) {
            translatedDDMFormField.setProperty("restUrl", ddmFormField.getProperty("restUrl"));
            translatedDDMFormField.setProperty("restKey", ddmFormField.getProperty("restKey"));
            translatedDDMFormField.setProperty("restValue", ddmFormField.getProperty("restValue"));
        }

        return translatedDDMFormField;
    }

    @Override
    public DDMFormField translate(
            com.liferay.dynamic.data.mapping.kernel.DDMFormField ddmFormField) {

        DDMFormField translatedFormField = super.translate(ddmFormField);

        if (ddmFormField.getType().equals("ddm-rest-select")) {
            translatedFormField.setProperty("restUrl", ddmFormField.getProperty("restUrl"));
            translatedFormField.setProperty("restKey", ddmFormField.getProperty("restKey"));
            translatedFormField.setProperty("restValue", ddmFormField.getProperty("restValue"));
        }

        return translatedFormField;
    }
}
