using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RecieveRayCast : MonoBehaviour
{
    public Renderer meshRenderer;
    public Material instanceMaterial;

    void Start()
    {
        meshRenderer = GetComponent<MeshRenderer>();
        instanceMaterial = meshRenderer.material;
    }

    public void SetHitPosition(Vector3 hitPoint)
    {
        Vector3 hitVector = gameObject.transform.InverseTransformPoint(hitPoint);
        instanceMaterial.SetVector("_HitPosition", hitVector);
    }
}
