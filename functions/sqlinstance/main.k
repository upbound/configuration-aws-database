import models.io.upbound.awsm.rds.v1beta1 as rdsv1beta1
import models.io.upbound.platform.aws.v1alpha1 as awsv1alpha1
import models.k8s.apimachinery.pkg.apis.meta.v1 as metav1

import base64

oxr = option("params").oxr # observed composite resource
_ocds = option("params").ocds # observed composed resources
_dxr = option("params").dxr # desired composite resource
dcds = option("params").dcds # desired composed resources

params = oxr.spec.parameters
providerConfigRefName = params.providerConfigName or None

_defaults = {
    managementPolicies = params.managementPolicies or ["*"]
    if providerConfigRefName:
        providerConfigRef = {
            kind = "ProviderConfig"
            name = providerConfigRefName
        }
    forProvider.region = params.region
}

_metadata = lambda name: str -> any {
    { annotations = { "krm.kcl.dev/composition-resource-name" = name }}
}

_items = [
    rdsv1beta1.SubnetGroup{
        metadata: _metadata("compositeSQLInstanceDbSubnetGroup")
        spec = _defaults | {
            forProvider: {
                description = "An excellent formation of subnetworks."
                subnetIdSelector.matchLabels = {
                    "networks.aws.platform.upbound.io/network-id" = params.networkRef.id
                }
            }
        }
    }
    rdsv1beta1.Instance{
        metadata: _metadata("RDSInstanceSmall")
        spec: _defaults | {
            forProvider: {
                dbName = "upbound"
                dbSubnetGroupNameSelector.matchControllerRef = True
                instanceClass = "db.t3.micro"
                publiclyAccessible = False
                skipFinalSnapshot = True
                username = "masteruser"
                engine = params.engine
                engineVersion = params.engineVersion
                allocatedStorage = params.storageGB
                vpcSecurityGroupIdSelector.matchLabels = {
                    "networks.aws.platform.upbound.io/network-id" = params.networkRef.id
                }
                autoGeneratePassword = params.autoGeneratePassword
                passwordSecretRef = {
                    name = params.passwordSecretRef.name
                    key = params.passwordSecretRef.key

                }
            }
            writeConnectionSecretToRef = {
                name = "{}-sql".format(oxr.metadata.name)
            }
        }
    }

    {
        apiVersion: "meta.krm.kcl.dev/v1alpha1"
        kind: "CompositeConnectionDetails"
        if "RDSInstanceSmall" in _ocds:
            data: {
                endpoint = _ocds["RDSInstanceSmall"].Resource?.status?.atProvider?.endpoint
                host = _ocds["RDSInstanceSmall"].Resource?.status?.atProvider?.address
                username = base64.encode(_ocds["RDSInstanceSmall"].Resource?.spec?.forProvider?.username)
                password = _ocds["RDSInstanceSmall"].ConnectionDetails.password
            }
        else:
            data: {}
    }
]
items = _items
