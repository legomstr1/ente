import {
    FlexWrapper,
    VerticallyCentered,
} from "@ente/shared/components/Container";
import DialogTitleWithCloseButton from "@ente/shared/components/DialogBox/TitleWithCloseButton";
import { Box, Button, Dialog, DialogContent, Typography } from "@mui/material";
import { t } from "i18next";
import { AppContext } from "pages/_app";
import { useContext, useEffect } from "react";
import billingService from "services/billingService";
import { preloadImage } from "utils/common";
import { getFamilyPlanAdmin } from "utils/user/family";

export function MemberSubscriptionManage({ open, userDetails, onClose }) {
    const { setDialogMessage, isMobile } = useContext(AppContext);

    useEffect(() => {
        preloadImage("/images/family-plan");
    }, []);

    async function onLeaveFamilyClick() {
        try {
            await billingService.leaveFamily();
        } catch (e) {
            setDialogMessage({
                title: t("ERROR"),
                close: { variant: "critical" },
                content: t("UNKNOWN_ERROR"),
            });
        }
    }
    const confirmLeaveFamily = () =>
        setDialogMessage({
            title: t("LEAVE_FAMILY_PLAN}"),
            content: t("LEAVE_FAMILY_CONFIRM"),
            proceed: {
                text: t("LEAVE"),
                action: onLeaveFamilyClick,
                variant: "critical",
            },
            close: {
                text: t("cancel"),
            },
        });

    if (!userDetails) {
        return <></>;
    }

    return (
        <Dialog
            open={open}
            onClose={onClose}
            maxWidth="xs"
            fullWidth
            fullScreen={isMobile}
        >
            <DialogTitleWithCloseButton onClose={onClose}>
                <Typography variant="h3" fontWeight={"bold"}>
                    {t("SUBSCRIPTION")}
                </Typography>
                <Typography color={"text.muted"}>{t("FAMILY_PLAN")}</Typography>
            </DialogTitleWithCloseButton>
            <DialogContent>
                <VerticallyCentered>
                    <Box mb={4}>
                        <Typography color="text.muted">
                            {t("subscription_info_family")}
                        </Typography>
                        <Typography>
                            {getFamilyPlanAdmin(userDetails.familyData)?.email}
                        </Typography>
                    </Box>

                    <img
                        height={256}
                        src="/images/family-plan/1x.png"
                        srcSet="/images/family-plan/2x.png 2x,
                                /images/family-plan/3x.png 3x"
                    />
                    <FlexWrapper px={2}>
                        <Button
                            size="large"
                            variant="outlined"
                            color="critical"
                            onClick={confirmLeaveFamily}
                        >
                            {t("LEAVE_FAMILY_PLAN")}
                        </Button>
                    </FlexWrapper>
                </VerticallyCentered>
            </DialogContent>
        </Dialog>
    );
}
